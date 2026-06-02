#!/usr/bin/env node
/*
 * run-ux-flow.js — drive the running app through core user flows and record
 * objective UX signals (load times, action success, feedback, errors).
 *
 * This is a generic harness. It auto-discovers a few common flows; for
 * product-specific flows, the grader can pass a flow spec file (see below).
 *
 * Usage:
 *   node scripts/run-ux-flow.js <baseURL> [outputDir] [flowsJsonPath]
 *
 *   baseURL        e.g. http://localhost:3000   (required)
 *   outputDir      where screenshots + results.json land  (default: /tmp/grade-ux)
 *   flowsJsonPath  optional JSON file describing flows (see FLOW SPEC below)
 *
 * FLOW SPEC (optional JSON):
 *   [
 *     {
 *       "name": "landing_to_signup",
 *       "steps": [
 *         { "action": "goto", "path": "/" },
 *         { "action": "click", "selector": "text=Sign up" },
 *         { "action": "fill", "selector": "input[name=email]", "value": "test@example.com" },
 *         { "action": "screenshot" }
 *       ]
 *     }
 *   ]
 *
 * Supported actions: goto, click, fill, waitFor, screenshot.
 *
 * Output: <outputDir>/results.json with per-flow timings, console errors,
 * failed network requests, and the step that broke (if any), plus screenshots.
 */
'use strict';

const fs = require('fs');
const path = require('path');

const baseURL = process.argv[2];
const outputDir = process.argv[3] || '/tmp/grade-ux';
const flowsPath = process.argv[4];

if (!baseURL) {
  console.error('Usage: node run-ux-flow.js <baseURL> [outputDir] [flowsJsonPath]');
  process.exit(1);
}

// Default flow when no spec is provided: just load the landing page and observe.
const DEFAULT_FLOWS = [
  { name: 'landing', steps: [{ action: 'goto', path: '/' }, { action: 'screenshot' }] },
];

let flows = DEFAULT_FLOWS;
if (flowsPath) {
  try {
    flows = JSON.parse(fs.readFileSync(flowsPath, 'utf8'));
  } catch (e) {
    console.error(`Could not read flows spec at ${flowsPath}: ${e.message}`);
    process.exit(1);
  }
}

(async () => {
  let chromium;
  try {
    ({ chromium } = require('playwright'));
  } catch (e) {
    console.error('Playwright not found. Run: npx --yes playwright install chromium --with-deps');
    process.exit(1);
  }

  fs.mkdirSync(outputDir, { recursive: true });
  const browser = await chromium.launch();
  const results = { baseURL, flows: [] };

  for (const flow of flows) {
    const context = await browser.newContext({ viewport: { width: 1280, height: 800 } });
    const page = await context.newPage();

    const consoleErrors = [];
    const failedRequests = [];
    page.on('console', (msg) => { if (msg.type() === 'error') consoleErrors.push(msg.text()); });
    page.on('requestfailed', (req) => failedRequests.push({ url: req.url(), error: req.failure()?.errorText }));
    page.on('response', (res) => { if (res.status() >= 400) failedRequests.push({ url: res.url(), status: res.status() }); });

    const flowResult = { name: flow.name, durationMs: 0, completed: false, brokeAtStep: null, consoleErrors, failedRequests };
    const start = Date.now();
    let stepIndex = 0;

    try {
      for (const step of flow.steps) {
        switch (step.action) {
          case 'goto':
            await page.goto(new URL(step.path || '/', baseURL).toString(), { waitUntil: 'networkidle', timeout: 30000 });
            break;
          case 'click':
            await page.click(step.selector, { timeout: 10000 });
            break;
          case 'fill':
            await page.fill(step.selector, step.value ?? '', { timeout: 10000 });
            break;
          case 'waitFor':
            await page.waitForSelector(step.selector, { timeout: 10000 });
            break;
          case 'screenshot':
            await page.screenshot({ path: path.join(outputDir, `${flow.name}-${stepIndex}.png`), fullPage: true });
            break;
          default:
            throw new Error(`Unknown action: ${step.action}`);
        }
        stepIndex++;
      }
      flowResult.completed = true;
    } catch (err) {
      flowResult.brokeAtStep = { index: stepIndex, step: flow.steps[stepIndex], error: err.message };
    } finally {
      flowResult.durationMs = Date.now() - start;
      results.flows.push(flowResult);
      await context.close();
    }
  }

  await browser.close();
  fs.writeFileSync(path.join(outputDir, 'results.json'), JSON.stringify(results, null, 2));
  console.log(JSON.stringify(results, null, 2));
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
