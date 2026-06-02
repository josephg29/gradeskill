# Backend Rubric (Server Code & APIs)

Grade the server-side code — APIs, data layer, business logic, infrastructure concerns.

## 6 Aspects (each gets a letter grade A–F plus good/improve notes)

### 1. API Design
- Are endpoints RESTful (or consistently follow another pattern: RPC, GraphQL)?
- Are resource names consistent (plural nouns, consistent casing)?
- Are HTTP methods used correctly (GET reads, POST creates, etc.)?
- Are status codes appropriate (404 vs 400 vs 500)?
- Are request/response shapes consistent across endpoints?

**A:** Clean design, consistent shapes, predictable from endpoint name alone.
**B:** Mostly consistent with a few odd endpoints or status code mismatches.
**C:** Mostly consistent with some weird endpoints (`getUserById` mixed with `/users/list`).
**D:** Inconsistent naming, wrong methods used, status codes semi-ignored.
**F:** Chaotic naming, wrong methods throughout, status codes ignored.

### 2. Error Handling
- Are errors caught and handled (not silent or crashing)?
- Are error responses structured (consistent shape with code + message)?
- Are validation errors distinguishable from server errors?
- Is sensitive info (stack traces, internal paths) kept out of error responses?

**A:** Centralized error handling, structured responses, validation vs server errors clearly separated.
**B:** Good handling in most places, with occasional inconsistent shapes or missing paths.
**C:** Try/catch in most places but error shapes vary, occasional unhandled paths.
**D:** Patchy handling. Some paths crash. Stack traces sometimes leak to clients.
**F:** Errors crash the server, raw stack traces sent to clients, errors swallowed silently.

### 3. Data Model
- Are schemas/models well-organized?
- Are relationships clear (foreign keys, joins, references)?
- Are field names consistent (camelCase or snake_case, not mixed)?
- Are types used (TypeScript, Pydantic, Zod, etc.)?
- Are migrations versioned (not edited in place)?

**A:** Clean schema, typed end-to-end, sensible relationships, migrations versioned.
**B:** Solid schema with minor naming inconsistencies or partial typing.
**C:** Schema exists but ad hoc, partial typing, inconsistent naming.
**D:** Weak schema, mostly untyped, fields added manually rather than migrated.
**F:** Untyped, redundant fields, no migrations, no clear data model.

### 4. Security
- Are env vars used for secrets (not hardcoded in source)?
- Is auth implemented properly (not just relying on obscurity)?
- Are user inputs validated and sanitized before DB queries?
- Are there obvious injection risks (raw SQL with string concatenation)?
- Is CORS configured tightly (not just `*`)?

**A:** Auth done right, inputs validated everywhere, secrets externalized, no obvious holes.
**B:** Auth in place, most inputs validated, CORS reasonable, secrets mostly externalized.
**C:** Basic auth, some validation, CORS too permissive, occasional secret in code.
**D:** Auth incomplete or bypassable, significant validation gaps, secrets in repo.
**F:** No auth, secrets hardcoded, raw SQL string concatenation, wide-open CORS.

**Critical:** Hardcoded secrets or credentials in source cap this aspect at D regardless of other factors. Flag it loudly in the notes.

### 5. Code Organization
- Are routes/controllers/services separated (not 1000-line route files)?
- Is business logic separated from HTTP handling?
- Are utilities and helpers organized into appropriate modules?
- Can you tell what each file does from its name and location?

**A:** Clear separation of concerns (routes → controllers → services → data layer).
**B:** Good structure with occasional business logic leaking into route handlers.
**C:** Some structure but business logic mixed with route handlers in places.
**D:** Mostly monolithic. Hard to locate logic. Related things spread across unrelated files.
**F:** One giant file (or a few). No separation at all. Can't find anything.

### 6. Performance
- Are there obvious N+1 queries?
- Is data fetched once and reused (not refetched inside loops)?
- Are heavy operations async/streamed where appropriate?
- Is there any caching where it would help significantly?
- Are DB queries indexed (visible from schema or migration files)?

**A:** Thoughtful query patterns, caching where useful, no obvious inefficiencies.
**B:** Good patterns with one or two inefficiencies that'll only matter at scale.
**C:** Works fine at small scale, some inefficiencies that'll bite at scale.
**D:** Multiple N+1 patterns, no indexes evident, blocking calls on hot paths.
**F:** N+1 queries everywhere, no indexes, blocking ops throughout the main path.

## How to score

For each of the 6 aspects:
1. Assign a letter grade (A/B/C/D/F) based on what you find in the code.
2. Write 1–3 sentences on **what was good** about this aspect.
3. Write 1–3 sentences on **what needs improving** — reference specific files and line numbers where possible.

Derive numeric score for averaging: A=95, B=82, C=73, D=63, F=45. Average the six numeric scores for the overall Backend grade.

If grading a frontend-only project with no backend code, return: "No backend detected — grading skipped" and exclude from the GPA in `everything` mode.
