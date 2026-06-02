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
/grade <category> loop         → grade → fix → regrade, repeat until the score plateaus (max 5 rounds)
/grade <category> loop <N>     → same as loop, but capped at N rounds
```

Categories:
- `ui` — visual quality of the frontend (looks, polish, consistency)
- `backend` — server code, API design, data handling
- `code` — overall code quality, structure, maintainability
- `ux` — actual usage flow (requires running the product)
- `everything` — runs all four and produces a combined report

If the user types just `/grade` with no category, ask which category they want.

## How to parse the command

Read the full command string. Extract:
1. **Category** — one of `ui`, `backend`, `code`, `ux`, `everything`
2. **Modifier** — none, `revise`, `loop`, or `loop <N>`

If the modifier is `loop` without a number, default to a max of 5 rounds with a plateau check (stop early if the score moves less than 3 points between rounds).

## Step 1: Detect the project context

Before grading, briefly inspect the repo to understand what you're looking at:

```bash
ls -la
cat package.json 2>/dev/null || cat pyproject.toml 2>/dev/null || cat Cargo.toml 2>/dev/null
```

Identify:
- Framework (React, Vue, SvelteKit, Next.js, Django, FastAPI, etc.)
- Whether there's a runnable dev server (look for `dev`, `start`, `serve` scripts)
- Project size (rough file count)

This shapes which rubric criteria apply. A static landing page isn't graded the same as a full-stack app.

## Step 2: Grade

Run the grading process for the requested category. Each category has its own approach — see the sections below.

For `everything`, run all four categories. Combine into a single report with an overall GPA at the top.

**For every category, grade each of the 6 aspects individually.** For each aspect you must produce:
1. A **letter grade** (A/B/C/D/F)
2. A **"Good:"** note — 1–3 sentences on what specifically worked well
3. An **"Improve:"** note — 1–3 sentences on what specifically needs work, with file names or screen names

The overall category grade is derived from the 6 aspect grades (A=95, B=82, C=73, D=63, F=45, averaged).

### Grading UI (looks)

UI grading is purely visual. **You must take screenshots of the actual rendered product** — do not grade from looking at JSX or CSS alone.

**Setup:**

1. Start the dev server in the background:
   ```bash
   npm run dev > /tmp/devserver.log 2>&1 &
   ```
   Wait 5-10 seconds, then check the log to confirm the port.

2. Install Playwright if not present:
   ```bash
   npx playwright install chromium --with-deps 2>/dev/null || pip install playwright && playwright install chromium
   ```

3. Take screenshots at multiple viewport sizes. Use this Playwright script (write it to `/tmp/screenshot.js`):
   ```javascript
   const { chromium } = require('playwright');
   (async () => {
     const browser = await chromium.launch();
     const url = process.argv[2] || 'http://localhost:3000';
     const viewports = [
       { name: 'desktop', width: 1440, height: 900 },
       { name: 'tablet', width: 768, height: 1024 },
       { name: 'mobile', width: 375, height: 812 }
     ];
     for (const vp of viewports) {
       const page = await browser.newPage({ viewport: vp });
       await page.goto(url, { waitUntil: 'networkidle' });
       await page.screenshot({ path: `/tmp/grade-ui-${vp.name}.png`, fullPage: true });
     }
     await browser.close();
   })();
   ```
   Run: `node /tmp/screenshot.js http://localhost:<port>`

4. If the app has multiple routes (dashboard, settings, etc.), grab screenshots of each major page.

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

1. Start the dev server (same as UI).

2. Write a Playwright test script that performs the core user flows. Identify these flows by looking at the README, main routes, and primary CTAs. Examples:
   - Landing page → sign up → onboarding
   - Login → main dashboard → primary action
   - Form submission → success/error state

3. The script should record:
   - Page load times
   - Whether actions complete successfully
   - Error states the user might hit
   - Number of clicks/inputs to complete each flow
   - Whether feedback is given (loading states, success messages)

   Example skeleton (`/tmp/ux-test.js`):
   ```javascript
   const { chromium } = require('playwright');
   (async () => {
     const browser = await chromium.launch();
     const page = await browser.newPage();
     const results = { flows: [] };
     
     const start = Date.now();
     await page.goto('http://localhost:3000');
     await page.screenshot({ path: '/tmp/ux-1-landing.png' });
     results.flows.push({ name: 'landing_to_signup', duration_ms: Date.now() - start });
     
     console.log(JSON.stringify(results, null, 2));
     await browser.close();
   })();
   ```

4. Run the script. Inspect the screenshots and results.

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

If the command was `/grade <category> loop [N]`, run this loop:

1. Grade (you've already done round 1)
2. Apply all fixes from the fix list
3. **Spawn a fresh subagent** to regrade with no context from previous rounds. This is critical — using your existing context biases the new grade.

   Use the Task tool:
   ```
   Task: Grade the <category> of the codebase at <repo path> using the codebase-grader skill. 
   Produce a report card. Return the final grade and score. 
   You have NO context from previous grading rounds — grade fresh.
   ```

4. Compare scores. Stop if:
   - You've hit the max rounds (5 by default, or N if specified)
   - The score moved less than 3 points from the previous round (plateau)
   - The score went down (regression — flag this clearly)

5. After the final round, generate a **summary report** showing:
   - Score progression across all rounds (line chart or table)
   - Final grade vs starting grade
   - What changed in each round

Save the loop summary to `grade-loop-summary-<timestamp>.html` and open it.

## Rubric files

Detailed scoring criteria live in `references/`:
- `rubric-ui.md` — visual quality dimensions
- `rubric-backend.md` — server code dimensions  
- `rubric-code.md` — code quality dimensions
- `rubric-ux.md` — usage flow dimensions

Read the relevant rubric file at the start of each grading run. Do not grade from memory of past runs.

## Scoring scale

All aspects use the same letter grades:
- **A**: Exceptional. Production-quality with polish.
- **B**: Solid. Real product, minor issues.
- **C**: Functional. Works but rough.
- **D**: Weak. Significant problems.
- **F**: Broken or missing.

Numeric conversion for averaging: A=95, B=82, C=73, D=63, F=45.

The category score = average of its 6 aspect numeric scores, rounded to the nearest integer. The category letter grade is derived from: 90+ = A, 78+ = B, 68+ = C, 58+ = D, else F.

For `everything`, the overall GPA uses: A=4.0, B=3.0, C=2.0, D=1.0, F=0.0, averaged across the four category grades.

## Tone and honesty

Be honest in the grading. The point of the report card is to drive real improvement — inflated grades defeat the purpose. If something is a C, call it a C and explain why. Be specific in the feedback ("the button labels in the settings page have inconsistent capitalization" beats "inconsistent styling").

That said, also call out what's actually good. A report card with only criticism isn't useful either.

## When NOT to use this skill

- The user wants a code review on a specific file or PR (use normal review, not grading)
- The user wants linter output or test results (use the linter/test runner)
- The user wants design feedback without a numeric score (just give feedback)
