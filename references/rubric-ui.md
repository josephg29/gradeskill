# UI Rubric (Visual Quality)

Grade what the screenshots actually look like. Do NOT grade code quality here — that's the `code` category. Grade the rendered output.

## Dimensions (each scored 0-100, then averaged)

### 1. Visual hierarchy
- Is it clear what's most important on each screen?
- Do headings, CTAs, and primary actions stand out?
- Are weights, sizes, and spacing used purposefully?

**A:** Eye is immediately drawn to the right things. Clear primary/secondary/tertiary hierarchy.
**C:** Hierarchy exists but is muddled — competing focal points, similar weights everywhere.
**F:** Flat, no hierarchy. Everything feels like the same importance.

### 2. Typography
- Are font choices appropriate to the product's tone?
- Is the type scale consistent (e.g., clear h1/h2/h3/body sizes)?
- Line height, letter spacing, and line length comfortable to read?
- Is there contrast between display and body type?

**A:** Strong type pairing, consistent scale, comfortable readability.
**C:** Default system fonts used flatly, weak scale, occasional awkward sizing.
**F:** Mixed fonts randomly, inconsistent sizes, hard to read.

### 3. Color and contrast
- Is the color palette coherent (not random)?
- Is contrast sufficient for accessibility (text on backgrounds)?
- Are accent colors used purposefully (not everywhere)?
- Does the palette serve the brand/tone?

**A:** Distinctive palette used with restraint. Strong contrast. Feels intentional.
**C:** Generic palette (default Tailwind grays + one blue). Adequate contrast.
**F:** Clashing colors, low contrast, no clear palette.

### 4. Spacing and layout
- Is there consistent rhythm (spacing follows a system like 4px/8px increments)?
- Do elements have room to breathe?
- Is alignment consistent across the page?
- Are containers, padding, and margins coherent?

**A:** Tight spacing system, generous whitespace, perfect alignment.
**C:** Spacing exists but uneven — some elements cramped, others floating.
**F:** Cramped or chaotic, misaligned, no rhythm.

### 5. Consistency
- Do buttons look like buttons across the app?
- Are form fields styled the same way?
- Is iconography from one set (not mixed Material + Feather + emoji)?
- Do similar components behave/look similar across screens?

**A:** Clearly built on a design system. Repeatable patterns.
**C:** Mostly consistent with occasional one-offs.
**F:** Every component looks like a different person built it.

### 6. Polish and detail
- Are there hover/focus states?
- Are loading and empty states designed (not just blank)?
- Are images and graphics high-quality (not stretched/pixelated)?
- Are edges, shadows, and corners refined?

**A:** Micro-interactions, designed empty/loading states, refined details.
**C:** Functional but rough edges — placeholder text visible, missing states.
**F:** Broken images, raw HTML defaults, glaring visual bugs.

### 7. Responsiveness
- Does the layout adapt at tablet and mobile widths?
- Are touch targets large enough on mobile?
- Does text reflow comfortably?
- Are images and media responsive?

**A:** Designed for each breakpoint, mobile feels native.
**C:** Works on mobile but cramped or oddly scaled.
**F:** Desktop layout shoved into mobile, horizontal scroll, broken.

## How to score

For each dimension, assign a 0-100 score. Average the seven scores for the overall UI grade. Round to the nearest integer.

When generating the "what was good / what wasn't / fixes" sections, reference specific screens and elements — not vague statements. "The signup form on `/signup` has misaligned labels" is useful. "Forms are inconsistent" is not.
