# UI Rubric (Visual Quality)

Grade what the screenshots actually look like. Do NOT grade code quality here — that's the `code` category. Grade the rendered output.

## 6 Aspects (each gets a letter grade A–F plus good/improve notes)

### 1. Visual Hierarchy
- Is it clear what's most important on each screen?
- Do headings, CTAs, and primary actions stand out?
- Are weights, sizes, and spacing used purposefully to create focus?

**A:** Eye immediately goes to the right things. Clear primary/secondary/tertiary layering.
**B:** Hierarchy mostly works with minor competing focal points.
**C:** Muddled — similar weights everywhere, multiple things fighting for attention.
**D:** Weak signal. Important actions blend into surrounding content.
**F:** Flat. Everything the same visual weight. No focal point.

### 2. Typography
- Are font choices appropriate to the product's tone?
- Is the type scale consistent (clear h1/h2/h3/body hierarchy)?
- Are line height, letter spacing, and line length comfortable to read?

**A:** Strong type pairing, consistent scale, comfortable readability throughout.
**B:** Good type with minor scale inconsistencies or slightly tight/loose leading.
**C:** Default system fonts used flatly, weak scale, occasional awkward sizing.
**D:** Inconsistent sizes, poor readability, type tone mismatch.
**F:** Mixed fonts randomly, inconsistent sizes, hard to read.

### 3. Color & Contrast
- Is the color palette coherent (not random)?
- Is contrast sufficient for accessibility (text on backgrounds)?
- Are accent colors used purposefully, not everywhere?

**A:** Distinctive palette used with restraint. Strong contrast. Feels intentional.
**B:** Good palette with minor over-use of accent or slightly low contrast in places.
**C:** Generic palette (default grays + one blue). Adequate contrast.
**D:** Clashing or muddy colors. Some contrast failures.
**F:** No clear palette. Low contrast throughout. Random color use.

### 4. Spacing & Layout
- Is there consistent rhythm (4px/8px-based system)?
- Do elements have room to breathe?
- Is alignment consistent? Are containers, padding, and margins coherent?

**A:** Tight spacing system, generous whitespace, perfect alignment everywhere.
**B:** Mostly consistent with occasional crowding or misalignment.
**C:** Spacing exists but uneven — some elements cramped, others floating.
**D:** No clear system. Alignment inconsistent. Crowded or over-spaced sections.
**F:** Chaotic. Misaligned. No rhythm. Elements overlap or bleed.

### 5. Consistency
- Do buttons look like buttons across the whole app?
- Are form fields styled the same way everywhere?
- Is iconography from one set (not mixed icon libraries)?
- Do similar components look and behave the same across screens?

**A:** Clearly built on a design system. Repeatable patterns everywhere.
**B:** Mostly consistent with a handful of one-off components.
**C:** Mostly consistent with occasional outliers.
**D:** Noticeable inconsistency — same element styled differently on different pages.
**F:** Every component looks like a different person built it.

### 6. Polish & Detail
- Are there hover/focus/active states on interactive elements?
- Are loading and empty states designed (not just blank or spinner-only)?
- Are images and graphics high quality (not stretched or pixelated)?
- Are edges, shadows, and corners refined and intentional?

**A:** Micro-interactions present, designed empty/loading states, refined details throughout.
**B:** Most states covered, a few missing or rough.
**C:** Functional but rough edges — placeholder text visible, some states missing.
**D:** Most states missing, only the happy path styled.
**F:** Broken images, raw HTML defaults, glaring visual bugs.

## How to score

For each of the 6 aspects:
1. Assign a letter grade (A/B/C/D/F) based on what you see in the screenshots.
2. Write 1–3 sentences on **what was good** about this aspect.
3. Write 1–3 sentences on **what needs improving** — be specific, reference actual screens and elements.

Derive the numeric score for averaging: A=95, B=82, C=73, D=63, F=45. Average the six numeric scores for the overall UI grade.

When noting specifics, reference actual screens and elements — "the signup form on `/signup` has misaligned labels" not "forms are inconsistent".
