# Codebase Grader

A [Claude Code](https://claude.com/claude-code) skill that grades your codebase like a report card — letter grades (A–F), numeric scores, what's working, what isn't, and a prioritized fix list. It produces a styled HTML report card and opens it in your browser.

Optionally, it can run an **audit → fix → regrade loop** that drives your scores up automatically.

## What it grades

| Category      | What it looks at                                                        | How |
|---------------|-------------------------------------------------------------------------|-----|
| `ui`          | Visual quality of the frontend — looks, polish, consistency             | Screenshots the rendered app via Playwright |
| `backend`     | Server code, API design, data handling, error handling                  | Code inspection |
| `code`        | Overall code quality, structure, maintainability, tests                 | Repo-wide structural review |
| `ux`          | The actual usage flow — clicks, load times, feedback, error states      | Drives the app with Playwright |
| `everything`  | All four, combined into one report with an overall GPA                   | Runs all of the above |

## Usage

Type one of these in Claude Code:

```
/grade ui                  → grade and open the HTML report
/grade backend             → grade the server code
/grade code                → grade overall code quality
/grade ux                  → grade the real usage flow
/grade everything          → grade all four + overall GPA

/grade ui revise           → grade, then fix the issues in one pass
/grade code loop           → grade → fix → regrade until the score plateaus (max 5 rounds)
/grade code loop 3         → same, but capped at 3 rounds

/grade self-test           → verify the skill install is healthy (grades nothing)
```

You can also just ask Claude to "grade", "audit", "score", or "make a report card" for your codebase, UI, or backend — the skill triggers on those too.

## How it works

- **Project detection** runs first ([`scripts/detect-project.sh`](./scripts/detect-project.sh)) to find your stack and the right dev command — npm, pnpm, yarn, bun, Django, FastAPI, Flask, Cargo, Go, or a static site — instead of assuming `npm run dev`.
- **UI / UX grading** renders your app with Playwright ([`scripts/screenshot-ui.js`](./scripts/screenshot-ui.js), [`scripts/run-ux-flow.js`](./scripts/run-ux-flow.js)) and grades the actual pixels and flows at desktop, tablet, and mobile viewports — not your JSX or CSS.
- **Backend / code grading** inspects the repo structure, routes, models, and patterns.
- Every run scores against a detailed rubric in [`references/`](./references) so grades stay consistent.
- The **loop** mode regrades with a fresh subagent (no memory of prior rounds) so improvements are measured honestly rather than graded on a curve, saving each round as `grade-report-round-N.html`.

## Example output

Open [`sample-report.html`](./sample-report.html) in a browser to see the report card the skill produces — overall grade, per-category and per-aspect letter grades, good/improve notes, and a prioritized fix list. The template that renders it lives in [`assets/report-template.html`](./assets/report-template.html).

### Scoring scale

| Grade | Score   | Meaning                                  |
|-------|---------|------------------------------------------|
| **A** | 90–100  | Exceptional. Production-quality polish.  |
| **B** | 80–89   | Solid. Real product, minor issues.       |
| **C** | 70–79   | Functional. Works but rough.             |
| **D** | 60–69   | Weak. Significant problems.              |
| **F** | <60     | Broken or incomplete.                    |

## Installation

Claude Code skills live in `~/.claude/skills/`. Clone this repo into a folder named after the skill:

```bash
git clone https://github.com/josephg29/gradeskill.git ~/.claude/skills/grade
```

Then restart Claude Code (or start a new session) and run `/grade code` in any project.

Verify the install at any time:

```bash
bash ~/.claude/skills/grade/scripts/self-test.sh   # or: /grade self-test
```

**Requirements:**
- [Claude Code](https://claude.com/claude-code)
- Node.js + `npx` (Playwright is installed on demand for `ui` and `ux` grading)
- A runnable dev server in your project (e.g. `npm run dev`) for `ui` and `ux` grading

## Repository layout

```
.
├── SKILL.md                 # The skill definition Claude reads
├── references/              # Detailed scoring rubrics
│   ├── rubric-ui.md
│   ├── rubric-backend.md
│   ├── rubric-code.md
│   └── rubric-ux.md
├── scripts/                 # Reusable helpers (no per-run improvising)
│   ├── detect-project.sh    # Detect stack + dev command
│   ├── screenshot-ui.js     # Multi-viewport screenshots for `ui`
│   ├── run-ux-flow.js       # Drive user flows for `ux`
│   └── self-test.sh         # Verify the install
├── assets/
│   └── report-template.html # HTML template for the report card
├── sample-report.html       # Example output
└── CHANGELOG.md             # Versioned history
```

## Limitations

- `ui`/`ux` grading requires a **runnable local app**. If it can't start (missing `.env`, Docker-only, auth wall with no test credentials), those categories are skipped — `backend` and `code` still work from inspection.
- Auth-gated apps need **test credentials** to grade flows past the login screen.
- Backend grading is **inspection-based**, not a full security audit or pen-test.
- Scores are **opinionated guidance**, not absolute truth — the goal is to drive concrete improvement.

## License

[MIT](./LICENSE)
