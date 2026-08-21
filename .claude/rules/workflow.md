# Workflow Rules

## Planning Before Acting

When asked to fix a bug or implement a feature, always confirm the plan before making any edits. Provide a brief summary of:
- What will change and why
- Which files will be modified or created

Wait for explicit approval before proceeding.

## Architecture Uncertainty

If unsure about the right architectural approach, do not guess and implement. Instead:
- Write out the general idea and the options you are considering
- Explain the trade-offs or unknowns
- Wait for approval or direction before proceeding

## Reusing Existing Code

When building a new view or feature, always search `Core` and `CoreUI` first for reusable components, utilities, or styles before writing new code.

## Extending Core / CoreUI

If something is missing from `Core` or `CoreUI` but would logically belong there (i.e., it will be used across the codebase), do not add it unilaterally. Instead:
- Explain what you want to add and why it belongs in `Core`/`CoreUI`
- Ask for permission
- Wait for approval before making any changes

## Feature Spec Files

Every module has behavioural spec markdown file(s) in its `Docs/` folder, describing how it works. A module
with screens has one spec per screen (`<Module>/Docs/<ScreenName>Screen.md`); a service-only module has one for
the module (`<Module>/Docs/<Module>.md`).

**A spec describes what is built, and nothing else.** No deferred work, no "not built yet" sections, no future
plans, and **no ticket references**. A developer must be able to read it and know what the app does today. The
board is where unbuilt work lives; a spec that mixes the two stops being trustworthy.

Keep them short and scannable — bullets and tables over prose, and short paragraphs where prose is needed.
Describe *how it behaves*, not how the code is structured.

At the **end of any work that touches a module**, you must:
- **Update the relevant spec file(s)** to reflect the behaviour you changed, added, or removed.
- **Re-check the spec against the implementation**: every statement in it must still be true. If a behaviour
  was intentionally changed, update the spec. If something the spec claims is missing from the code, flag it
  rather than quietly deleting either side.

If a module has no spec file yet and your work meaningfully defines its behaviour, create one in the same
format.

## Backlog (Jira)

All deferred work — bugs, tech debt, open questions, deferred parts of a feature, "do it later" items —
lives on the **Zeitnot** Jira board (project `ZN`, https://thorssons.atlassian.net/browse/ZN).
Whenever we decide to postpone something — defer a fix, punt on a decision, leave a feature partially
done — **create a Jira issue** instead of letting it disappear.

Each issue must carry a **type of work** (feature, bug, chore, refactor, etc.) — the same types that
drive branch names (see Git → Branch Naming). Write a clear title and put the full context in the
description. The Jira board is the single source of truth for deferred work — there is no `backlog.md`.

## Git

### Two Levels Of Branch

Work is organised in two levels, mirroring the Jira hierarchy:

- **Epic branch** (a.k.a. the *feature branch*) — one per Epic, cut from `develop`. It is the
  integration point for everything in that Epic. The developer opens its PR and applies the
  **feature branch** tag.
- **Ticket branch** — one per ticket, cut from **its Epic's branch**, never from `develop`.

```
develop
 └── feat/ZN-2-setup-screen              ← epic branch (PR tagged "feature branch")
      ├── feat/ZN-5-preset-ruleset-list  ← ticket branches
      ├── feat/ZN-7-custom-stepper-section
      └── bugfix/ZN-9-stepper-selection-state
```

Ticket branches merge back into their Epic branch; the Epic branch merges into `develop`. Both
merges are the developer's job.

### Branch Naming

Both levels use the same format — nothing in the name distinguishes an Epic branch from a ticket
branch; the PR tag does that.

```
<type>/<TICKET-ID>-<title-separated-by-words>
```

- `<type>` — the branch prefix for that issue's **own** type of work (table below).
- `<TICKET-ID>` — the Jira key, e.g. `ZN-23`.
- `<title-separated-by-words>` — the issue title, lowercased, words separated by hyphens.

| Type of work | Prefix     |
|--------------|------------|
| Feature      | `feat`     |
| Bug          | `bugfix`   |
| Chore        | `chore`    |
| Refactor     | `refactor` |

Each issue must carry a type of work. Ask for it only if it isn't given and can't be inferred from
the issue.

### Starting Work

Creating and publishing branches is **mandatory and automatic** — the first thing Claude does,
before any code edits. This is never a "want me to create the branch?" question and never an
ask-first step; it is a standard part of starting the work.

**Given an Epic to start:**

1. Create the Epic branch off `develop` (`git checkout develop && git pull && git checkout -b <branch>`).
2. Publish it (`git push -u origin <branch>`).
3. Tell the developer the branch is up so they can open its PR and tag it **feature branch**.

**Given a ticket to start (e.g. a bare ticket ID):**

1. **Look up the ticket's parent Epic in Jira** to determine which branch it belongs on. Do not ask
   the developer which base to use — resolve it from the issue's parent.
2. Ensure the Epic's branch exists. If it does not, create and publish it off `develop` first, and
   then **explicitly report that you created it**, so the developer knows a new PR needs the
   feature-branch tag.
3. Create the ticket branch off the Epic's branch (`git checkout <epic-branch> && git checkout -b <branch>`).
4. Publish it (`git push -u origin <branch>`).
5. Only then begin the actual work.

Never start work directly on `develop` or on an Epic branch — tickets always get their own branch.
Never treat the branch as optional or defer it until "the change is ready": the empty branch goes up
first, before the first edit.

The push is allowed **only** to create a branch remotely. A branch Claude pushes must carry no new
commits authored by Claude. Pushing commits is still forbidden (see below).

### Forbidden

Committing is still done by the developer, who wants to review the code first. Claude must never:
- Stage or commit any changes
- Push commits to any branch (publishing an empty new branch to the remote is allowed — see Starting Work)
- Create or modify pull requests, or add/change PR labels and tags

Claude may only create branches (including publishing an empty branch to the remote) and write/modify
files. Leave all other version control actions to the developer.
