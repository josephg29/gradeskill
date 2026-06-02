# Backend Rubric (Server Code & APIs)

Grade the server-side code — APIs, data layer, business logic, infrastructure concerns.

## Dimensions (each scored 0-100, then averaged)

### 1. API design
- Are endpoints RESTful (or consistently follow some other pattern like RPC/GraphQL)?
- Are resource names consistent (plural nouns, kebab/snake-case used consistently)?
- Are HTTP methods used correctly (GET for reads, POST for creates, etc.)?
- Are status codes appropriate (404 vs 400 vs 500)?
- Are request/response shapes consistent across endpoints?

**A:** Clean RESTful design, consistent shapes, predictable from endpoint name alone.
**C:** Mostly consistent with some weird endpoints. `getUserById` mixed with `/users/list`.
**F:** Chaotic naming, wrong methods, status codes ignored.

### 2. Error handling
- Are errors caught and handled gracefully (not silent or crashing)?
- Are error responses structured (consistent shape with code + message)?
- Are validation errors distinguishable from server errors?
- Is sensitive info leaked in error messages?

**A:** Centralized error handling, structured responses, validation vs server errors clearly separated.
**C:** Try/catch in most places but error shapes vary, occasional unhandled paths.
**F:** Errors crash the server, raw stack traces leak to clients, swallowed errors.

### 3. Data model
- Are schemas/models well-organized?
- Are relationships clear (foreign keys, joins, references)?
- Are field names consistent (camelCase vs snake_case used throughout, not mixed)?
- Are types used (TypeScript types, Pydantic models, Zod schemas)?
- Are migrations versioned (not edited in place)?

**A:** Clean schema, typed end-to-end, sensible relationships, migrations versioned.
**C:** Schema exists but ad hoc, partial typing, inconsistent naming.
**F:** Untyped, redundant fields, no migrations, fields manually added in production.

### 4. Security basics
- Are env vars used for secrets (not hardcoded)?
- Is auth implemented (not just relying on obscurity)?
- Are user inputs validated and sanitized before DB queries?
- Are there obvious injection risks (raw SQL with string concat)?
- Is CORS configured (not just `*`)?
- Are rate limits or basic abuse protection in place?

**A:** Auth done right, inputs validated, secrets externalized, no obvious holes.
**C:** Basic auth in place, some validation, CORS too permissive, secrets sometimes in code.
**F:** No auth, secrets in repo, raw SQL string concatenation, wide-open CORS.

**Critical:** If hardcoded secrets, API keys, or credentials are found in the code, the security score caps at 50 regardless of other factors. Flag it loudly.

### 5. Code organization
- Are routes/controllers/services separated (not 1000-line route files)?
- Is business logic separated from HTTP handling?
- Are utilities and helpers organized?
- Can you tell what each file is for from its name and location?

**A:** Clear separation of concerns (routes → controllers → services → data).
**C:** Some structure but business logic mixed with route handlers.
**F:** Monolithic files, no separation, hard to find anything.

### 6. Performance considerations
- Are there obvious N+1 queries?
- Is data fetched once and reused (not refetched in loops)?
- Are heavy operations async/streamed where appropriate?
- Is there any caching where it would help?
- Are DB queries indexed (if visible from schema/migration files)?

**A:** Thoughtful query patterns, caching where useful, no obvious inefficiencies.
**C:** Works fine at small scale, some inefficiencies that'll bite at scale.
**F:** N+1 queries everywhere, no indexes, blocking ops on the main path.

### 7. Documentation and config
- Is there a README explaining how to run the backend?
- Are env vars documented (`.env.example` or similar)?
- Are non-obvious decisions commented?
- Are setup steps reproducible?

**A:** Clear README, `.env.example`, runnable in one command.
**C:** README exists but partial, env vars half-documented.
**F:** No README, no idea what env vars are needed, requires tribal knowledge.

## How to score

Average the seven dimensions. Round to the nearest integer.

If grading a frontend-only project with no backend code, return a special note: "No backend detected — grading skipped" and exclude from the GPA in `everything` mode.

For the "what was good / what wasn't / fixes" sections, reference specific files and line numbers where possible.
