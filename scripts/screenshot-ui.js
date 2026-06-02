#!/usr/bin/env node
/*
 * screenshot-ui.js — capture full-page screenshots of a running app for UI grading.
 *
 * Usage:
 *   node scripts/screenshot-ui.js <baseURL> [outputDir] [routes]
 *
 *   baseURL    e.g. http://localhost:3000   (required)
 *   outputDir  where PNGs are written        (default: /tmp/grade-ui)
 *   routes     comma-separated paths to also capture, e.g. "/,/dashboard,/settings"
 *              (default: "/")
 *
 * Each route is captured at desktop (1440×900), tablet (768×1024) and
 * mobile (375×812) viewports. Output files are named:
 *   <outputDir>/<route-slug>-<viewport>.png
 *
 * Requires Playwright. Install once with:
 *   npx --yes playwright install chromium --with-deps
 *
 * Exits 0 on success, 1 if the browser/page could not load anything.
 */
'use strict';

const fs = require('fs');
const path = require('path');

const baseURL = process.argv[2];
const outputDir = process.argv[3] || '/tmp/grade-ui';
const routes = (process.argv[4] || '/').split(',').map((r) => r.trim()).filter(Boolean);

if (!baseURL) {
  console.error('Usage: node screenshot-ui.js <baseURL> [outputDir] [routes]');
  process.exit(1);
}

const VIEWPORTS = [
  { name: 'desktop', width: 1440, height: 900 },
  { name: 'tablet', width: 768, height: 1024 },
  { name: 'mobile', width: 375, height: 812 },
];

function slug(route) {
  const s = route.replace(/^\/+|\/+$/g, '').replace(/[^a-z0-9]+/gi, '-');
  return s || 'home';
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
  const captured = [];
  const failed = [];

  for (const route of routes) {
    const url = new URL(route, baseURL).toString();
    for (const vp of VIEWPORTS) {
      const context = await browser.newContext({ viewport: { width: vp.width, height: vp.height } });
      const page = await context.newPage();
      const file = path.join(outputDir, `${slug(route)}-${vp.name}.png`);
      try {
        await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
        // Give late-loading fonts/images a moment to settle.
        await page.waitForTimeout(800);
        await page.screenshot({ path: file, fullPage: true });
        captured.push(file);
      } catch (err) {
        failed.push({ url, viewport: vp.name, error: err.message });
      } finally {
        await context.close();
      }
    }
  }

  await browser.close();

  console.log(JSON.stringify({ outputDir, captured, failed }, null, 2));
  if (captured.length === 0) {
    console.error('No screenshots captured — is the dev server running at ' + baseURL + '?');
    process.exit(1);
  }
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
