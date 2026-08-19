#!/usr/bin/env bash
#
# Vendors the Claude Code skills declared in skills.manifest.json into ../skills/,
# pinning each to an exact upstream commit recorded in skills.lock.json.
#
# Usage:
#   ./sync-skills.sh            Re-vendor every skill and rewrite skills.lock.json.
#   ./sync-skills.sh --check    Report which skills have drifted from their pinned
#                               commit. Touches no files. Exits non-zero on drift.
#   ./sync-skills.sh --check --notify
#                               As --check, plus a macOS notification when drift is found
#                               (used by the weekly LaunchAgent — see README.md).
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILLS_DIR="$REPO_ROOT/.claude/skills"
MANIFEST="$SCRIPT_DIR/skills.manifest.json"
LOCK="$SCRIPT_DIR/skills.lock.json"

CHECK=false
NOTIFY=false
for arg in "$@"; do
    case "$arg" in
        --check) CHECK=true ;;
        --notify) NOTIFY=true ;;
        *) echo "Unknown argument: $arg" >&2; exit 2 ;;
    esac
done

command -v jq >/dev/null || { echo "error: jq is required" >&2; exit 2; }
command -v git >/dev/null || { echo "error: git is required" >&2; exit 2; }

# Resolve a branch/tag ref on a remote to its commit SHA.
resolve_remote_sha() {
    local repo="$1" ref="$2"
    git ls-remote "$repo" "$ref" 2>/dev/null | awk 'NR==1 {print $1}'
}

notify() {
    "$NOTIFY" || return 0
    command -v osascript >/dev/null || return 0
    osascript -e "display notification \"$1\" with title \"Zeitnot skills\"" >/dev/null 2>&1 || true
}

# ----------------------------------------------------------------------------- check
if "$CHECK"; then
    [ -f "$LOCK" ] || { echo "error: $LOCK not found — run ./sync-skills.sh first" >&2; exit 2; }

    drift=0
    while IFS=$'\t' read -r name repo subpath ref; do
        locked="$(jq -r --arg n "$name" '.skills[$n].commit // ""' "$LOCK")"
        remote="$(resolve_remote_sha "$repo" "$ref")"
        if [ -z "$remote" ]; then
            printf '  ?  %-32s could not reach %s@%s\n' "$name" "$repo" "$ref"
            continue
        fi
        if [ "$locked" = "$remote" ]; then
            printf '  ✓  %-32s up to date (%s)\n' "$name" "${locked:0:7}"
        else
            printf '  ⬆  %-32s %s → %s  (upstream moved)\n' "$name" "${locked:0:7}" "${remote:0:7}"
            drift=$((drift + 1))
        fi
    done < <(jq -r '.skills[] | [.name, .repo, .subpath, .ref] | @tsv' "$MANIFEST")

    if [ "$drift" -gt 0 ]; then
        echo
        echo "$drift skill(s) drifted. Run ./sync-skills.sh to update, then review the diff."
        notify "$drift skill(s) have upstream updates. Run sync-skills.sh."
        exit 1
    fi
    echo
    echo "All skills up to date."
    exit 0
fi

# ----------------------------------------------------------------------------- sync
mkdir -p "$SKILLS_DIR"
TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

lock_entries=()

while IFS=$'\t' read -r name repo subpath ref; do
    echo "→ $name  ($repo @ $ref : $subpath)"
    work="$TMP_ROOT/$name"

    git clone --quiet --depth 1 --filter=blob:none --sparse --branch "$ref" "$repo" "$work"
    git -C "$work" sparse-checkout set "$subpath" >/dev/null
    sha="$(git -C "$work" rev-parse HEAD)"

    src="$work/$subpath"
    [ -f "$src/SKILL.md" ] || { echo "error: no SKILL.md at $repo/$subpath" >&2; exit 1; }

    dest="$SKILLS_DIR/$name"
    rm -rf "$dest"
    mkdir -p "$dest"
    # Copy the skill's contents (not the subpath folder itself); drop any .git metadata.
    rsync -a --exclude '.git' "$src/" "$dest/"

    echo "  vendored @ ${sha:0:7}"
    lock_entries+=("$(jq -n \
        --arg name "$name" --arg repo "$repo" --arg subpath "$subpath" \
        --arg ref "$ref" --arg commit "$sha" \
        '{($name): {repo: $repo, ref: $ref, subpath: $subpath, commit: $commit}}')")
done < <(jq -r '.skills[] | [.name, .repo, .subpath, .ref] | @tsv' "$MANIFEST")

generated="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
printf '%s\n' "${lock_entries[@]}" \
    | jq -s --arg generated "$generated" \
        '{generated: $generated, skills: (reduce .[] as $e ({}; . + $e))}' \
    > "$LOCK"

echo
echo "Wrote $(jq '.skills | length' "$LOCK") skill(s) to skills.lock.json (generated $generated)."
