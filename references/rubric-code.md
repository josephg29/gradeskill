# Code Rubric (Code Quality & Structure)

Grade the codebase as a whole — structure, maintainability, hygiene. Separate from UI (visual) and backend (API/server) — this rubric is about code itself.

## 6 Aspects (each gets a letter grade A–F plus good/improve notes)

### 1. File & Folder Structure
- Is there a clear top-level layout (e.g., `src/`, `components/`, `lib/`, `tests/`)?
- Are similar files grouped together?
- Is the depth reasonable (not 8 levels deep, not flat with 200 files in `src/`)?
- Can you find things based on name alone?

**A:** Intuitive layout, related files colocated, clear conventions followed consistently.
**B:** Good structure with a handful of files in the wrong place or inconsistent grouping.
**C:** Some structure but inconsistent — random files in root, unclear grouping.
**D:** Minimal organization. Hard to predict where anything lives.
**F:** Chaotic. Hundreds of files in one folder. Can't find anything.

### 2. Naming
- Are variable, function, and component names descriptive?
- Are conventions consistent (camelCase, snake_case, PascalCase used predictably)?
- Are file names meaningful (`UserCard.tsx` vs `comp1.tsx`)?
- Are abbreviations obvious to a new reader?

**A:** Names read like English, consistent conventions, self-documenting throughout.
**B:** Mostly clear with a few cryptic names or mixed conventions in one area.
**C:** Mostly clear with occasional `temp`, `data2`, or one-letter variables.
**D:** Significant naming confusion — abbreviations unclear, conventions inconsistent.
**F:** Cryptic abbreviations, mixed conventions, names that lie about what the code does.

### 3. Duplication
- Is the same logic copy-pasted across files?
- Are utility functions used for repeated patterns?
- Are components reused vs recreated?

Use grep to find repeated function bodies, repeated JSX patterns, and repeated string constants.

**A:** DRY where it matters. Minimal duplication. Shared utilities used consistently.
**B:** Light duplication in 1–2 areas, otherwise well-abstracted.
**C:** Some duplication — same logic in 2–3 places.
**D:** Significant duplication — key logic duplicated in 4+ places.
**F:** Massive duplication. Same function rewritten 5+ times with slight variations.

### 4. Complexity
- Are individual files reasonable size (most under 300 lines)?
- Are functions short and focused (under 50 lines)?
- Are there deeply nested conditionals or loops (>4 levels)?
- Are there functions with 8+ parameters?

Use `wc -l` to spot oversized files, then read them to assess.

**A:** Files and functions stay focused. Complex logic broken into small, named pieces.
**B:** A few oversized functions or files, but the rest well-scoped.
**C:** Some bloated files. Occasional deep nesting. Most functions reasonable.
**D:** Several multi-hundred-line functions. Frequent deep nesting. Hard to follow.
**F:** Multi-thousand-line files. 200-line functions. Nested 6+ levels deep.

### 5. Hygiene
- Is there commented-out code lying around?
- Are there `console.log`s left in production paths?
- Are `TODO`/`FIXME` comments stale (no owner, no date)?
- Does `.gitignore` exclude the right things (`node_modules`, `.env`, `dist`)?
- Are generated files or build artifacts committed to the repo?

Search with grep for `console.log`, `// TODO`, large commented blocks.

**A:** Clean — no dead code, console logs gated behind dev flags, gitignore proper.
**B:** A few stale TODOs or console logs, otherwise clean.
**C:** Some console logs and TODOs. Mostly clean otherwise.
**D:** Frequent debug logs, commented-out blocks, or build artifacts in the repo.
**F:** Dead code everywhere. Debug logs throughout. Build artifacts committed.

### 6. Testing
- Are there any tests at all?
- Do tests cover the critical paths (not just trivial helpers)?
- Are tests structured and named clearly?
- Is there a test command that just works (`npm test`, `pytest`, etc.)?

**A:** Real test coverage on important paths. Tests pass. Clear structure and naming.
**B:** Solid tests on most important paths with some gaps.
**C:** Tests exist but cover trivial things or have significant gaps.
**D:** Very thin test coverage. Tests present but don't cover anything meaningful.
**F:** Zero tests, or tests exist but all broken/skipped.

For early-stage prototype projects, note the context — a v0.1 prototype missing tests is less concerning than a production app missing them. Adjust your notes accordingly but still assign an honest grade.

## How to score

For each of the 6 aspects:
1. Assign a letter grade (A/B/C/D/F) based on what you find in the code.
2. Write 1–3 sentences on **what was good** about this aspect.
3. Write 1–3 sentences on **what needs improving** — cite specific files (e.g., "`src/utils/helpers.ts` is 1,247 lines with 38 unrelated functions").

Derive numeric score for averaging: A=95, B=82, C=73, D=63, F=45. Average the six numeric scores for the overall Code grade.
