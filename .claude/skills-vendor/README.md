# Vendored Claude Code skills

This folder vendors third-party [Claude Code skills](https://docs.claude.com/en/docs/claude-code/skills)
into [`.claude/skills/`](../skills) so they are **committed into the repo** — every teammate gets the
same skills, pinned to an exact upstream commit, working offline with no extra setup.

The skills here are all about **writing Swift / SwiftUI**, so they trigger automatically when Claude
works on this app's code.

| Skill | Upstream | What it helps with |
|---|---|---|
| `swiftui-expert-skill` | [AvdLee/SwiftUI-Agent-Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill) | SwiftUI state/data flow, view composition, performance, Liquid Glass, Instruments traces |
| `swift-concurrency` | [AvdLee/Swift-Concurrency-Agent-Skill](https://github.com/AvdLee/Swift-Concurrency-Agent-Skill) | async/await, actors, `@MainActor`, `Sendable`, Swift 6 migration |

## Files

- `skills.manifest.json` — the source of truth: which skills, from where, at which `ref`.
- `skills.manifest.schema.json` — JSON Schema the manifest validates against.
- `sync-skills.sh` — (re)vendors the skills and rewrites the lock file.
- `skills.lock.json` — generated; records the exact commit each skill was vendored from.

## How it works

`sync-skills.sh` reads the manifest, sparse-clones each upstream repo at its `ref`, copies the
declared `subpath` into `.claude/skills/<name>/`, and pins the resolved commit SHA in
`skills.lock.json`. The vendored skill folders are an exact copy of upstream — **don't hand-edit
them**; they get overwritten on the next sync. To change a skill, fork it upstream (or change the
`ref`/`repo` in the manifest) and re-sync.

Requires `jq`, `git`, and `rsync` on `PATH`.

## Common tasks

**Re-vendor everything (after changing the manifest, or to pull updates):**
```bash
.claude/skills-vendor/sync-skills.sh
```
Then review the diff under `.claude/skills/` and commit.

**Check for upstream updates without changing anything:**
```bash
.claude/skills-vendor/sync-skills.sh --check
```
Prints `✓` for up-to-date skills and `⬆` for ones whose upstream `ref` has moved past the pinned
commit. Exits non-zero if anything drifted.

**Add a skill:** add an entry to `skills.manifest.json` (`name` should match the skill's own
`SKILL.md` name), then run `sync-skills.sh`.

**Remove a skill:** delete its manifest entry, run `sync-skills.sh` to refresh the lock, then
`rm -rf .claude/skills/<name>`.

Skills are scanned at session start — restart Claude Code after a sync for changes to take effect.
