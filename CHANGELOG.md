# Changelog

All notable changes to the `grade` skill are documented here. This project
follows [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- `scripts/detect-project.sh` — detects stack and the correct dev command
  (npm / pnpm / yarn / bun, Django / FastAPI / Flask, Cargo, Go, static) instead
  of assuming `npm run dev`.
- `scripts/screenshot-ui.js` — reusable multi-viewport screenshot capture for `ui`,
  parameterized by URL, output dir, and routes.
- `scripts/run-ux-flow.js` — reusable UX harness that drives flows from a JSON spec
  and records timings, completion, console errors, and failed requests.
- `scripts/self-test.sh` and the `/grade self-test` command — verify the install
  (frontmatter, template, rubrics, scripts, writable output, Node/Playwright).
- **Limitations** sections in `README.md` and `SKILL.md`.
- Print/PDF stylesheet in `assets/report-template.html`.
- "Example output" section in the README pointing at `sample-report.html`.
- This changelog.

### Changed
- Grading flow now runs project detection first and uses the detected dev command
  and confirmed port rather than hardcoded `npm run dev` / port 3000.
- Loop mode saves each round as `grade-report-round-N.html` and documents a
  fresh-regrade fallback when the Task tool is unavailable.

### Fixed
- Stale `codebase-grader` references left over from the rename to `grade`
  (README install path, report template footer, sample report footer, loop
  subagent prompt).

## [0.2.0]
- Per-aspect grading: each category scores its 6 aspects with individual letter
  grades plus good/improve notes.

## [0.1.0]
- Initial `grade` skill: `ui` / `backend` / `code` / `ux` / `everything` modes,
  rubrics, HTML report template, and sample report.
