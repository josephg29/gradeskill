# UX Rubric (Usage Flow & Friction)

Grade the actual experience of using the product. **You must use the product before grading** — run flows in Playwright, click around, attempt the core actions. Do NOT grade UX from looking at code alone.

## Dimensions (each scored 0-100, then averaged)

### 1. First impression and orientation
- When you land on the home/start page, is it clear what the product does?
- Is the primary action obvious within 5 seconds?
- Is there a way to get started without reading documentation?
- Does the page load quickly (under 3 seconds to interactive)?

**A:** Instantly clear what to do. Strong call-to-action. Loads fast.
**C:** Eventually clear but takes work to figure out. Maybe a generic landing page.
**F:** No idea what this is or what to do. Confusing entry.

### 2. Task flow clarity
- Can you complete the core user task (the main thing the product does) without getting stuck?
- Are steps in a logical order?
- Is the path forward always clear (next button, next step indicator)?
- Can you go back if you make a mistake?
- Are there dead ends or pages with no obvious next step?

**A:** Smooth path through core tasks, never wondering what to do next.
**C:** Tasks completable but with detours, occasional moments of "now what?"
**F:** Dead ends, hidden steps, can't figure out how to complete the main action.

### 3. Friction
- How many clicks to complete the core task?
- Are forms asking for unnecessary information?
- Are there repeated confirmations or popups?
- Do you have to enter the same data twice?
- Are there modals or overlays interrupting flow?

Count clicks. Note repeated inputs. Note interruptions.

**A:** Minimum viable steps to get value. No unnecessary friction.
**C:** Some bloat — extra confirmation modals, redundant fields.
**F:** 15 clicks to do a 2-click task. Constant interruptions.

### 4. Feedback and state
- When you click something, do you get visual feedback (loading spinner, state change)?
- When an action completes, is there success feedback?
- When something fails, is the error message clear and actionable?
- Are loading states designed (not just frozen UI)?
- Are empty states helpful (not just blank screens)?

**A:** Every action has clear feedback. Errors tell you exactly what to do.
**C:** Most actions give feedback, but errors are generic ("something went wrong").
**F:** Click and pray. No feedback. Errors are stack traces or silent.

### 5. Discoverability
- Can you find secondary features without a tutorial?
- Are settings, profile, and key navigation clearly labeled?
- Are icons paired with labels (not icon-only)?
- Are advanced features available without being in the way?

**A:** Everything findable through the UI alone. No hunting.
**C:** Main features discoverable, advanced stuff hidden in unintuitive places.
**F:** Need to read docs to find anything beyond the main flow.

### 6. Error recovery and edge cases
- What happens if you submit a form with bad data? (Try it.)
- What happens if you go to a route that doesn't exist? (Try `/asdf123`.)
- What happens if you refresh mid-flow? (Try it.)
- What happens if you don't fill in required fields?

Test these. Don't just hope they work.

**A:** Graceful recovery from all tested edge cases. Helpful error states.
**C:** Some cases handled, some show generic errors or break.
**F:** Bad inputs crash the app, 404s show stack traces, no recovery.

### 7. Accessibility basics
- Are interactive elements keyboard-reachable (tab through them)?
- Are focus states visible?
- Do form fields have labels (not just placeholders)?
- Is text contrast sufficient?
- Are images alt-tagged (check the DOM)?

**A:** Keyboard navigable, visible focus, proper labels, good contrast.
**C:** Mostly works with keyboard but focus states are inconsistent.
**F:** Mouse-only, no focus styles, placeholder-as-label, low contrast.

## How to test

Before scoring, run a Playwright script that:

1. **Loads the home page** — capture timing, screenshot
2. **Identifies the primary CTA** — read the page, find the main button
3. **Attempts the core flow** — sign up, create something, complete the main action
4. **Tries edge cases** — empty form, invalid data, refresh mid-flow, nonexistent route
5. **Tests keyboard nav** — tab through, check focus
6. **Records timings and click counts** for each step

Log results to a JSON file. Screenshot at each step.

Example skeleton:
```javascript
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch();
  const ctx = await browser.newContext();
  const page = await ctx.newPage();
  const results = { flows: [], edge_cases: [], timings: {} };
  
  // 1. Landing
  const t0 = Date.now();
  await page.goto('http://localhost:3000', { waitUntil: 'networkidle' });
  results.timings.landing = Date.now() - t0;
  await page.screenshot({ path: '/tmp/ux-01-landing.png' });
  
  // 2. Primary CTA — find the most prominent button
  // (You'll need to read the page and decide what the primary action is)
  
  // 3. Edge case: 404
  await page.goto('http://localhost:3000/this-route-does-not-exist');
  await page.screenshot({ path: '/tmp/ux-02-404.png' });
  
  // 4. Edge case: empty form submit
  // ...
  
  console.log(JSON.stringify(results, null, 2));
  await browser.close();
})();
```

## How to score

Average the seven dimensions. Round to the nearest integer.

For the "what was good / what wasn't / fixes" sections, reference specific flows ("the signup flow takes 6 clicks where 3 would suffice — the email confirmation modal is the main offender").

If the product won't run (build errors, can't start dev server), set UX score to 0 and note in the report. Cannot grade UX without a running product.
