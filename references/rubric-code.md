# Code Rubric (Code Quality & Structure)

Grade the codebase as a whole — structure, maintainability, hygiene. This is separate from UI (visual) and backend (API/server) — Code looks at code itself.

## Dimensions (each scored 0-100, then averaged)

### 1. File and folder structure
- Is there a clear top-level layout (e.g., `src/`, `components/`, `lib/`, `tests/`)?
- Are similar files grouped together?
- Is the depth reasonable (not 8 levels deep, not flat with 200 files in `src/`)?
- Can you find things based on name alone?

**A:** Intuitive layout, related files colocated, clear conventions followed.
**C:** Some structure but inconsistent — random files in the root, unclear grouping.
**F:** Chaotic, hundreds of files in one folder, can't find anything.

### 2. Naming
- Are variable, function, and component names descriptive?
- Are conventions consistent (camelCase vs snake_case used throughout)?
- Are file names meaningful (`UserCard.tsx` vs `comp1.tsx`)?
- Are there abbreviations that aren't clear?

**A:** Names read like English, consistent conventions, self-documenting.
**C:** Mostly clear with occasional `temp`, `data2`, or one-letter variables.
**F:** Cryptic abbreviations, mixed conventions, names lie about what code does.

### 3. Duplication
- Is the same logic copy-pasted across files?
- Are there utility functions for repeated patterns?
- Are components reused vs recreated?

Check with grep for repeated function bodies, repeated JSX patterns, or repeated string constants.

**A:** DRY where it should be, minimal duplication, shared utilities used.
**C:** Some duplication but mostly contained — same logic in 2-3 places.
**F:** Massive duplication, same function rewritten 5 times with slight variations.

### 4. Complexity
- Are individual files reasonable size (most under 300 lines)?
- Are functions short and focused (under 50 lines, ideally)?
- Are there deeply nested conditionals or loops?
- Are there functions with 8+ parameters?

Use `wc -l` to spot oversized files, then read them to assess.

**A:** Files and functions stay focused. Complex logic broken into pieces.
**C:** Some bloated files but most reasonable. Occasional deep nesting.
**F:** Multi-thousand-line files, 200-line functions, nested 6 deep.

### 5. Dependencies and config
- Is `package.json` (or equivalent) clean — no unused deps?
- Are dependencies pinned or floating reasonably?
- Are config files (tsconfig, eslint, prettier) present and sensible?
- Is there a lockfile committed?

**A:** Lean deps, clean config, lockfile committed, no warnings on install.
**C:** Reasonable deps but some unused, config present but default.
**F:** 200 dependencies, half unused, no lockfile, config files in conflict.

### 6. Hygiene
- Is there commented-out code lying around?
- Are there `console.log`s left in production paths?
- Are there `TODO`/`FIXME` comments without owners or dates?
- Is there a `.gitignore` that excludes the right things (node_modules, .env, dist)?
- Are there generated files or builds committed?

Search with grep for `console.log`, `// TODO`, large commented blocks.

**A:** Clean — no dead code, console logs gated behind dev flags, gitignore proper.
**C:** Some console logs and TODOs, mostly clean otherwise.
**F:** Commented-out blocks everywhere, debug logs in prod, build artifacts committed.

### 7. Testing
- Are there any tests at all?
- Do tests cover the critical paths (not just trivial helpers)?
- Are tests structured and named clearly?
- Is there a test command that just works?

**A:** Real test coverage on important paths, tests pass, clear structure.
**C:** Some tests exist but cover trivial things, partial coverage.
**F:** Zero tests, or tests exist but are broken/skipped.

For early-stage prototype projects, weight this dimension lower — note it but don't tank the grade purely for missing tests on a v0.1 project.

### 8. Documentation
- Is there a README that explains what the project is?
- Are setup instructions clear and complete?
- Are non-obvious decisions documented (architecture, why a weird workaround exists)?
- Are exports/public APIs documented?

**A:** Clear README, setup works on first try, key decisions noted.
**C:** Basic README, setup partially documented, no architecture notes.
**F:** No README or just the framework default, no docs at all.

## How to score

Average the eight dimensions. Round to the nearest integer.

For each dimension, use ripgrep/grep/find/wc liberally — measure first, then read. Cite specific files in the report (e.g., "`src/utils/helpers.ts` is 1,247 lines and contains 38 unrelated functions").
