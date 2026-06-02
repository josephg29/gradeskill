---
name: grade
description: Grade codebases like a report card with letter grades (A-F), numeric scores, and prioritized fix lists. Triggers on `/grade ui`, `/grade backend`, `/grade code`, `/grade ux`, `/grade everything`, optionally with `revise` or `loop [N]` modifiers. Produces a styled HTML report card and opens it. Use this skill any time the user types a `/grade` command, or asks to "grade", "audit", "review", "score", or "report card" a codebase, frontend, backend, UI, or UX. Also use when the user wants to iteratively improve a codebase based on grading feedback.
---

# Codebase Grader

A grading system for codebases that produces a report card-style HTML output with letter grades, a breakdown of what's working, what isn't, and a prioritized fix list. Optionally runs an audit-fix-regrade loop to drive scores up.

## Command structure

The user invokes this skill with commands like:

```
/grade <category>              → grade and open the HTML report
/grade <category> revise       → grade, then fix issues in one pass
/grade <category> loop         → grade → fix → regrade, repeat until improvement stalls below the noise floor (max 5 rounds)
/grade <category> loop <N>     → same as loop, but capped at N rounds
/grade self-test               → verify the skill install is healthy (no project graded)
```

Categories:
- `ui` — visual quality of the frontend (looks, polish, consistency)
- `backend` — server code, API design, data handling
- `code` — overall code quality, structure, maintainability
- `ux` — actual usage flow (requires running the product)
- `everything` — runs all four and produces a combined report

If the user types just `/grade` with no category, ask which category they want.

If the user types `/grade self-test`, do not grade anything — run the install check described in **Self-test** below and report the result.

## How to parse the command

Read the full command string. Extract:
1. **Category** — one of `ui`, `backend`, `code`, `ux`, `everything`
2. **Modifier** — none, `revise`, `loop`, or `loop <N>`

If the modifier is `loop` without a number, default to a max of 5 rounds. **Do not stop on a fixed point threshold** — a hard "< 3 points" trigger is smaller than the grader's own measurement noise (see "The measurement-noise problem" below), so it fires on noise by design. Instead, stop when round-over-round improvement falls below the measured noise floor for two consecutive rounds. The mechanics are in Step 5.

## Step 1: Detect the project context

Before grading, figure out what you're looking at and — for `ui`/`ux` — how to run it. Use the bundled detector instead of assuming `npm`:

```bash
bash scripts/detect-project.sh .
```

It prints `STACK`, `PACKAGE_MANAGER`, `DEV_COMMAND`, `DEV_SCRIPT`, `HAS_DOCKER`, and `RUNNABLE`. It understands npm / pnpm / yarn / bun (via lockfiles and the `packageManager` field), Python (Django / FastAPI / Flask), Rust, Go, and plain static sites. **Use the reported `DEV_COMMAND` — do not hardcode `npm run dev`.**

Then look a little deeper yourself:
- Framework (React, Vue, SvelteKit, Next.js, Django, FastAPI, etc.)
- Project size (rough file count)
- Anything that blocks running it: required `.env` files, auth walls, a database dependency, a monorepo with the app in a sub-package, a non-default port.

This shapes which rubric criteria apply. A static landing page isn't graded the same as a full-stack app.

**If the app can't be run** (`RUNNABLE=no`, missing env, Docker-only, auth-gated with no test credentials): do not fake it. Tell the user exactly what's blocking, ask for what you need (a start command, credentials, an `.env`), and either grade the categories that don't require a running app (`backend`, `code`) or stop and wait. Never grade `ui`/`ux` from source alone — say so explicitly.

## Step 2: Grade

Run the grading process for the requested category. Each category has its own approach — see the sections below.

For `everything`, run all four categories. Combine into a single report with an overall GPA at the top.

**For every category, grade each of the 6 aspects individually.** For each aspect you must produce:
1. A **fine numeric score 0–100** — this is the real measurement. Score on the full continuous range, not snapped to a letter band. A genuine contrast fix that moves an aspect from 74 to 78 must be recordable as +4; if you only ever emit letter-band numbers (95/82/73/63/45) a real improvement quantizes to zero while ordinary grader jitter flips a whole letter (±6). **Numbers are the signal; letters are display only.**
2. A **letter grade** (A/B/C/D/F) derived from the numeric score, shown to the user.
3. A **"Good:"** note — 1–3 sentences on what specifically worked well.
4. An **"Improve:"** note — 1–3 sentences on what specifically needs work, with file names or screen names.

The overall category score is the average of the 6 aspect numeric scores. The category letter is derived from that average (see "Scoring scale"). Never average the letter-band stand-ins (95/82/73/…) — average the fine scores you actually assigned.

### Capture design intent (do this on the first grade)

On the **first** grade of a project, write a short **design-intent note** and save it to `references/.grade-intent-<category>.md` in the repo (create the file). It records deliberate choices a cold grader would otherwise re-litigate as failures — e.g. "the dark/light split between the marketing and app shells is intentional", "the pixel/bitmap display font is a brand decision, not a typography defect", "no empty-state illustration on the admin table is acceptable for an internal tool". Keep it to a handful of bullets.

Every subsequent grade (and every spawned grader subagent) **must read this note first** and treat listed choices as in-scope/by-design rather than scoring them down. If you believe an intentional choice is genuinely wrong, say so in the "Improve:" note explicitly — don't silently tank the score for it.

### Grading UI (looks)

UI grading is purely visual. **You must take screenshots of the actual rendered product** — do not grade from looking at JSX or CSS alone.

**Setup:**

1. Start the dev server in the background using the `DEV_COMMAND` from Step 1 (not a hardcoded `npm run dev`):
   ```bash
   <DEV_COMMAND> > /tmp/devserver.log 2>&1 &
   ```
   Wait 5-10 seconds, then read `/tmp/devserver.log` to confirm the **actual port** — frameworks pick different defaults (Next 3000, Vite 5173, SvelteKit 5173, Django 8000, etc.) and may auto-increment if the port is taken. Use the port the log reports, not an assumed one.

2. Install Playwright if not present (the bundled scripts use the Node build):
   ```bash
   npx --yes playwright install chromium --with-deps
   ```

3. Take screenshots with the bundled script — no need to re-write it each run:
   ```bash
   node scripts/screenshot-ui.js http://localhost:<port> /tmp/grade-ui "/,/dashboard,/settings"
   ```
   - Arg 1: base URL (use the confirmed port)
   - Arg 2: output dir (default `/tmp/grade-ui`)
   - Arg 3: comma-separated routes to capture (default `/`)

   It captures each route at desktop (1440×900), tablet (768×1024), and mobile (375×812) and prints a JSON manifest of what was captured and what failed. Capture every major route you found in Step 1.

4. If the script reports `captured: []` (nothing rendered), the server isn't actually up — re-check the log and port before grading. Do not grade `ui` without real screenshots.

**Grade each of the 6 UI aspects** from `references/rubric-ui.md` using your vision capability on the screenshots:
Visual Hierarchy · Typography · Color & Contrast · Spacing & Layout · Consistency · Polish & Detail

### Grading Backend

Backend grading is from code inspection. Look at:
- API route files (`api/`, `routes/`, `server/`, `controllers/`)
- Database/model files (`models/`, `db/`, `prisma/`, `schema.*`)
- Middleware, auth logic, environment config
- Error handling patterns across endpoints

Use Glob and Grep to find these. Read the key files.

**Grade each of the 6 Backend aspects** from `references/rubric-backend.md`:
API Design · Error Handling · Data Model · Security · Code Organization · Performance

### Grading Code

Code grading is structural. Walk the entire repo (excluding `node_modules`, `dist`, `build`, `.next`, etc.). Use `wc -l`, grep, and find to measure before reading.

**Grade each of the 6 Code aspects** from `references/rubric-code.md`:
File & Folder Structure · Naming · Duplication · Complexity · Hygiene · Testing

### Grading UX

UX grading requires **actually using the product**. This is the most involved category.

1. Start the dev server (same as UI — use the detected `DEV_COMMAND` and confirm the port).

2. Identify the core user flows by looking at the README, main routes, and primary CTAs. Examples:
   - Landing page → sign up → onboarding
   - Login → main dashboard → primary action
   - Form submission → success/error state

3. Describe those flows in a small JSON spec and run them with the bundled harness:
   ```bash
   cat > /tmp/flows.json <<'JSON'
   [
     { "name": "landing_to_signup", "steps": [
       { "action": "goto", "path": "/" },
       { "action": "screenshot" },
       { "action": "click", "selector": "text=Sign up" },
       { "action": "fill", "selector": "input[name=email]", "value": "test@example.com" },
       { "action": "screenshot" }
     ] }
   ]
   JSON
   node scripts/run-ux-flow.js http://localhost:<port> /tmp/grade-ux /tmp/flows.json
   ```
   Supported step actions: `goto`, `click`, `fill`, `waitFor`, `screenshot`. With no spec it just loads `/` and screenshots it.

   For each flow the harness records: load/flow duration, whether the flow completed, the step it broke on (if any), console errors, and failed network requests (4xx/5xx). Results land in `/tmp/grade-ux/results.json` plus screenshots.

4. Inspect the screenshots and `results.json`. Grade on the evidence — completion, friction (step count, broken steps), feedback (loading/success states visible in screenshots), and error recovery (what happens on the failed steps).

**Grade each of the 6 UX aspects** from `references/rubric-ux.md`:
First Impression & Orientation · Task Flow Clarity · Friction · Feedback & State · Discoverability · Error Recovery & Edge Cases

## Step 3: Compose the report

Read the HTML template at `assets/report-template.html`. Fill it in with:

- Overall grade and score (or GPA if `everything`)
- Per-category grade and score
- For each category, a grid of 6 aspect cards, each showing:
  - The aspect name and its letter grade
  - **Good:** 1–3 sentences on what worked
  - **Improve:** 1–3 sentences on what needs work (specific, with file/screen references)
- After the aspect grid, a prioritized **Fixes** list — numbered, ordered by impact

Write the filled report to `grade-report-<timestamp>.html` in the repo root. Open it:

```bash
# macOS
open grade-report-*.html
# Linux
xdg-open grade-report-*.html
```

Tell the user the file path so they can find it later.

## Step 4 (revise only): Apply fixes

If the command was `/grade <category> revise`, after generating the report, work through the fix list from highest to lowest priority. For each fix:

1. Make the change
2. Briefly state what you changed and why

After all fixes are applied, **do not regrade automatically** unless the command was `loop`. Just tell the user the fixes are done and suggest they re-run `/grade <category>` to see the new score.

## Step 5 (loop only): Run the iteration loop

### The measurement-noise problem (read this first)

The naive loop — "fix, then have a fresh cold grader re-roll one absolute score, and compare to last round" — is broken, and it will report that a codebase *got worse* when it actually improved. Here is why, and the loop below is built to defeat each cause:

- **The signal is below the noise floor.** A single cold grader re-judging the whole app from scratch has a per-round jitter of roughly **±6 points** (a different rater redraws every letter boundary). The real per-round improvement from a fix pass is roughly **2–6 points**. One score minus one score can't separate them.
- **Coarse quantization eats the signal.** Letter bands sit 9–13 points apart; a real fix rarely lifts an aspect a whole letter, so it rounds to zero — while jitter flips a letter and shows ±6. (The fine 0–100 scoring in Step 2 is half the fix; the rest is below.)
- **Whole-app re-grades resample unchanged surface.** ~95% of the app is identical between rounds, yet a from-scratch grader re-samples all of it and the unchanged part contributes most of the variance, drowning the 1–2 things that actually changed.
- **No anchors, no intent.** Without pinned exemplars and the design-intent note, each cold grader re-litigates intentional choices and redraws bands, adding more drift.

So: **regrade as a delta against the prior round, with a panel, anchored to prior per-aspect scores and the design-intent note — not as an independent absolute re-roll.**

### Establish the noise floor (once, before round 2)

Before trusting any round-over-round delta, measure the grader's own noise on this project:

1. With the build **unchanged**, spawn the grader **twice** (two independent subagents, same screenshots/inputs).
2. Take the absolute difference in overall score between the two runs. That gap (typically 4–8) is your **noise floor** for this project. If you ran a 3-grader panel, use the spread (max − min) of the panel.
3. A round's improvement only counts as **real** when it exceeds the noise floor. Record the noise floor in the summary so the user can see it.

### The loop

1. Grade (round 1 is done). Persist each aspect's **fine numeric score**, the **design-intent note**, and the round-1 report as `grade-report-round-1.html` so progress is auditable.
2. Apply all fixes from the fix list (highest priority first). Keep a **changelog**: which files changed and which aspects each change targets.
3. **Regrade as a delta, with a panel.** Spawn **2–3 fresh grader subagents** (independent context, to avoid self-confirmation bias) but give each one an anchored, diff-aware brief — not a blank-slate re-roll:

   ```
   Task (general-purpose): Re-grade the <category> of the codebase at <repo path> using the grade skill.
   This is a DELTA re-grade, not a fresh absolute grade.
   - Read references/.grade-intent-<category>.md first. Treat everything listed there as
     intentional/in-scope — do NOT score it down.
   - Here are last round's per-aspect numeric scores: <paste the 6 numbers>.
   - Here is the changelog of what changed this round: <paste changelog>.
   For each aspect: HOLD last round's score unless the new screenshot/code shows a change
   for that aspect. Only move a score when you can point to the specific changed thing that
   justifies the move, and say what it was. Use the fine 0–100 scale.
   Return the 6 fine per-aspect scores and a one-line justification per aspect.
   ```

   **Fallback if the Task tool isn't available** in this environment: re-read the relevant `references/rubric-*.md` and the design-intent note from scratch, re-run the detection/screenshot/inspection steps from raw output (don't reuse prior screenshots or notes), then apply the same delta discipline yourself — hold each prior per-aspect score unless the new evidence shows a change. Note in the summary that the regrade was in-context rather than a fresh panel, which widens the noise floor.

4. **Reconcile the panel.** For each aspect, take the **median** of the panel's scores (median resists a single outlier rater). The round's overall score is the average of the 6 reconciled aspect scores. Save round N's report as `grade-report-round-<N>.html`.
5. **Decide whether to continue or stop.** Compare the reconciled overall score to the prior round:
   - **Improvement > noise floor** → real progress, continue.
   - **Improvement ≤ noise floor** → a stall; this is the plateau signal. Stop only after **two consecutive** sub-noise-floor rounds (one flat round can be noise).
   - **Apparent regression:** do **not** report "got worse" on a single round, and **never** report a regression when the only diffs this round were verified improvements (cross-check the changelog — if nothing got worse on disk, a lower number is the grader, not the app). Require a regression to **persist for two consecutive rounds** and to correspond to an actual change in the changelog before reporting it. If it persists and is real, flag it and revert the offending change.
   - **Max rounds reached** (5 by default, or N).

6. After the final round, generate a **summary report** showing:
   - Score progression across all rounds (line chart or table), using the **reconciled fine scores**.
   - The **noise floor**, drawn as a band around the line, so a flat-but-jittery run reads as flat — not as improvement or regression.
   - Final grade vs starting grade, and which changes drove the real (above-noise) gains.
   - What changed in each round (from the changelog).

Save the loop summary to `grade-loop-summary-<timestamp>.html` and open it.

> **Honesty rule for the loop:** the number you report is a noisy estimate, not a verdict. When the round-over-round move is inside the noise floor, say "flat (within measurement noise)" — do not narrate it as a rise or a drop. The point of the panel + anchors + noise floor is to stop the loop from inventing a trend that the measurement can't support.

## Rubric files

Detailed scoring criteria live in `references/`:
- `rubric-ui.md` — visual quality dimensions
- `rubric-backend.md` — server code dimensions  
- `rubric-code.md` — code quality dimensions
- `rubric-ux.md` — usage flow dimensions

Read the relevant rubric file at the start of each grading run. Do not grade from memory of past runs.

## Helper scripts

Reusable scripts live in `scripts/` so you don't re-improvise them each run:
- `scripts/detect-project.sh [dir]` — detect stack, package manager, and the right dev command.
- `scripts/screenshot-ui.js <url> [outDir] [routes]` — capture multi-viewport screenshots for `ui`.
- `scripts/run-ux-flow.js <url> [outDir] [flows.json]` — drive user flows and record UX signals for `ux`.
- `scripts/self-test.sh` — verify the install (see below).

Prefer these over writing ad-hoc scripts to `/tmp`. They take arguments, so they adapt per project without editing.

## Self-test

When the user runs `/grade self-test`, run:

```bash
bash scripts/self-test.sh
```

It checks that `SKILL.md` frontmatter is valid, the template and all four rubrics exist, the helper scripts are present and executable, the output directory is writable, and reports whether Node and Playwright are available (needed only for `ui`/`ux`). Relay the pass/fail summary. If a check fails, point the user at the specific missing/broken file.

## Scoring scale

**Score each aspect on a fine 0–100 scale — that number is the measurement.** Letters are a display rollup derived from the number, never the other way around. Do not snap aspect scores to band midpoints (95/82/73/63/45); those are only fallbacks for the band's *center*, and using them as the actual scores is what makes real improvements quantize to zero in the loop.

Number → letter bands:
- **A (90–100)**: Exceptional. Production-quality with polish.
- **B (80–89)**: Solid. Real product, minor issues.
- **C (70–79)**: Functional. Works but rough.
- **D (60–69)**: Weak. Significant problems.
- **F (<60)**: Broken or missing.

The category score = average of its 6 aspect fine scores, rounded to the nearest integer. The category letter is read off the same bands above.

For `everything`, the overall GPA uses: A=4.0, B=3.0, C=2.0, D=1.0, F=0.0, averaged across the four category grades.

### Calibration anchors (keeps grades stable across rounds)

A cold grader drifts because "B" is just prose ("good type with minor inconsistencies"). Pin it to *this project*. On the first grade, for each aspect write a one-line **anchor** describing what the current state looks like at its assigned score — e.g. *"Typography = 76: consistent scale, but the settings page mixes two body sizes."* Save these alongside the design-intent note (`references/.grade-intent-<category>.md`). Every later grade reads the anchors and scores **relative to them** ("is this better or worse than the pinned 76 example?") instead of redrawing the boundary from scratch. This is what keeps the same unchanged screen from drifting a full letter between raters.

## Tone and honesty

Be honest in the grading. The point of the report card is to drive real improvement — inflated grades defeat the purpose. If something is a C, call it a C and explain why. Be specific in the feedback ("the button labels in the settings page have inconsistent capitalization" beats "inconsistent styling").

That said, also call out what's actually good. A report card with only criticism isn't useful either.

## Limitations

Be upfront about these — both in conversation and, where relevant, in the report summary:

- **`ui`/`ux` grading requires a runnable local app.** If it can't start, those categories can't be graded — grade `backend`/`code` instead, or ask for what's needed to run it.
- **Auth-gated apps need test credentials.** Without them, `ux` can only grade the pre-login surface.
- **Backend grading is inspection-based, not a full security audit or pen-test.** Treat security notes as a first pass, not a clearance.
- **Scores are opinionated guidance, not ground truth.** The point is to drive concrete improvement, not to produce an authoritative number.
- **Grades depend on the rubric, not on lint/test results.** For objective build/test/lint signals, run those tools directly.

## When NOT to use this skill

- The user wants a code review on a specific file or PR (use normal review, not grading)
- The user wants linter output or test results (use the linter/test runner)
- The user wants design feedback without a numeric score (just give feedback)
