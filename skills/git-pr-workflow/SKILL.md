---
name: git-pr-workflow
description: "Use when creating a pull request or wrapping up a branch of work: keep git commit messages short/concise, and put the full rationale, summary, and test plan in the PR description via `gh pr create`. Triggers: \"raise a PR\", \"open a PR\", \"create a pull request\", \"ship this\", wrapping up a feature branch."
---

# Git PR workflow

Concise commits, detailed PRs. Don't cram context into a commit message — that's what the PR body is for.

## Workflow

1. **Check `gh` is ready.** Run `gh auth status`. If not authenticated, tell the user to run `! gh auth login` themselves (interactive device-code flow — don't try to drive it via Bash). If `gh` isn't installed, ask before `brew install gh`-ing it.
2. **Branch.** Create a feature branch off the default branch (`git checkout -b <descriptive-name>`) rather than committing straight to main, unless told otherwise.
3. **Stage deliberately.** `git add` the specific files belonging to this change — never blanket `-A` — after reviewing `git status`/`git diff` for anything unexpected (stray files, secrets, unrelated edits).
4. **Commit short.** One line, matching whatever convention the repo already uses (check `git log --oneline` first — e.g. gitmoji-prefixed). No bullet-point essay in the commit body; that belongs in the PR.
5. **Push** with `-u origin <branch>`.
6. **Open the PR** with `gh pr create --title "..." --body "$(cat <<'EOF' ... EOF)"` (heredoc keeps formatting/quoting clean). Body structure:
   - `## Summary` — bullets covering what changed *and why*: design decisions, tradeoffs, anything a reviewer would otherwise have to ask about.
   - `## Test plan` — checklist of what was actually verified (checked) vs. still outstanding (unchecked). Be honest about what wasn't tested (e.g. "not run against the live system, wasn't reachable from here").
7. **Report back the PR URL** — don't just say "done."

## Why

Commit history should read as a clean log of *what* happened; the PR is where the *why* and review context live. Terse commits also keep `git log --oneline` and `git blame` actually useful instead of noisy.
