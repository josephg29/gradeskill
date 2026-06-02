# UX Rubric (Usage Flow & Friction)

Grade the actual experience of using the product. **You must use the product before grading** — run flows in Playwright, click around, attempt the core actions. Do NOT grade UX from looking at code alone.

## 6 Aspects (each gets a letter grade A–F plus good/improve notes)

### 1. First Impression & Orientation
- When you land on the home/start page, is it clear what the product does?
- Is the primary action obvious within 5 seconds?
- Can you get started without reading documentation?
- Does the page load quickly (under 3 seconds to interactive)?

**A:** Instantly clear what to do. Strong call-to-action. Loads fast. Zero ambiguity.
**B:** Clear within 10 seconds with a small moment of "what's this?"
**C:** Eventually clear but takes work. Maybe a generic or vague landing page.
**D:** Unclear purpose. Primary action buried or absent.
**F:** No idea what this is or what to do. Confusing entry. Slow.

### 2. Task Flow Clarity
- Can you complete the core user task without getting stuck?
- Are steps in a logical order?
- Is the path forward always clear (next button, step indicators)?
- Can you go back if you make a mistake?
- Are there dead ends — pages with no obvious next step?

**A:** Smooth path through core tasks. Never wondering what to do next.
**B:** Core flow works with one or two moments of mild confusion.
**C:** Tasks completable but with detours. Occasional "now what?" moments.
**D:** Significant confusion mid-flow. Back navigation broken or inconsistent.
**F:** Dead ends. Hidden steps. Can't figure out how to complete the main action.

### 3. Friction
- How many clicks to complete the core task?
- Are forms asking for unnecessary information?
- Are there repeated confirmations or popups?
- Do you have to enter the same data twice?
- Are there modals or overlays interrupting flow?

Count actual clicks. Note repeated inputs. Note interruptions.

**A:** Minimum viable steps to get value. No unnecessary friction at all.
**B:** Mostly smooth with one unnecessary step or confirmation.
**C:** Some bloat — extra confirmation modals, redundant fields.
**D:** Noticeably high friction. Several unnecessary steps or repeated data entry.
**F:** 15 clicks to do a 2-click task. Constant interruptions.

### 4. Feedback & State
- When you click something, do you get visual feedback (loading spinner, state change)?
- When an action completes, is there success feedback?
- When something fails, is the error message clear and actionable?
- Are loading states designed (not just frozen UI)?
- Are empty states helpful (not just blank screens)?

**A:** Every action has clear feedback. Errors tell you exactly what to do. Empty states are helpful.
**B:** Most actions give feedback. One or two gaps in loading/empty state handling.
**C:** Most actions give feedback but errors are generic ("something went wrong").
**D:** Feedback is inconsistent. Many actions feel unacknowledged. Errors are vague.
**F:** Click and pray. No feedback. Errors are stack traces or silently fail.

### 5. Discoverability
- Can you find secondary features without a tutorial?
- Are settings, profile, and key navigation clearly labeled?
- Are icons paired with labels (not icon-only)?
- Are advanced features accessible without being in the way?

**A:** Everything findable through the UI alone. No hunting required.
**B:** Main features easy to find. One or two secondary features require guessing.
**C:** Main features discoverable. Advanced features hidden in unintuitive places.
**D:** Even core features take effort to find. Navigation labels unclear or missing.
**F:** Need to read docs to find anything beyond the main flow.

### 6. Error Recovery & Edge Cases
Test each of these manually — don't guess:
- Submit a form with bad/empty data. Does it tell you what's wrong?
- Go to a route that doesn't exist (`/asdf123`). What happens?
- Refresh mid-flow. Does state survive?
- Submit without filling required fields.

**A:** Graceful recovery from all tested edge cases. Helpful, specific error states.
**B:** Most cases handled well. One or two show generic errors.
**C:** Some cases handled, some show generic errors, one may break partially.
**D:** Several edge cases handled poorly. Some show raw errors or break silently.
**F:** Bad inputs crash the app. 404s show stack traces. No recovery path.

## How to test

Before scoring, run a Playwright script that:

1. **Loads the home page** — capture timing, screenshot
2. **Identifies the primary CTA** — read the page, find the main button
3. **Attempts the core flow** — sign up, create something, complete the main action
4. **Tries edge cases** — empty form, invalid data, refresh mid-flow, nonexistent route
5. **Tests keyboard nav** — tab through, check focus
6. **Records timings and click counts** for each step

Example skeleton (`/tmp/ux-test.js`):
```javascript
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch();
  const ctx = await browser.newContext();
  const page = await ctx.newPage();
  const results = { flows: [], edge_cases: [], timings: {} };
  
  const t0 = Date.now();
  await page.goto('http://localhost:3000', { waitUntil: 'networkidle' });
  results.timings.landing = Date.now() - t0;
  await page.screenshot({ path: '/tmp/ux-01-landing.png' });
  
  await page.goto('http://localhost:3000/this-route-does-not-exist');
  await page.screenshot({ path: '/tmp/ux-02-404.png' });
  
  console.log(JSON.stringify(results, null, 2));
  await browser.close();
})();
```

## How to score

For each of the 6 aspects:
1. Assign a letter grade (A/B/C/D/F) based on what you observe while using the product.
2. Write 1–3 sentences on **what was good** — specific flows or behaviors that worked well.
3. Write 1–3 sentences on **what needs improving** — reference specific flows ("the signup flow takes 6 clicks; the email confirmation modal is the main offender").

Derive numeric score for averaging: A=95, B=82, C=73, D=63, F=45. Average the six numeric scores for the overall UX grade.

If the product won't run (build errors, can't start dev server), set UX score to 0 and note it in the report. Cannot grade UX without a running product.
