# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A static-site playground with no build system, package manager, linter, or tests. The main deliverable is `sugar_and_bloom.html`, a single-file landing page for a fictional bakery ("Sugar & Bloom"). All HTML, CSS (in a `<style>` block), and vanilla JS (in a `<script>` block at the end of `<body>`) live in that one file. The only external dependency is Google Fonts (Playfair Display and Lato).

To view it, open the file in a browser or serve the directory with something like `python3 -m http.server`. There is nothing to compile.

## Architecture of `sugar_and_bloom.html`

The page is data-driven. Most visible content comes from JS constants at the top of the `<script>` block, so make content changes there, not in the markup:

- `CAKES` holds each cake's id, name, flavor, base price (for a 6" cake), copy, and a `colors` object. The menu grid (`#menuGrid`) is rendered from this array, and so is each cake's illustration.
- `SIZES` lists the size options, each with a `mult` multiplier applied to the base price.
- `cakeSVG(cake, tiers)` draws every cake illustration as inline SVG from the cake's `colors`. There are no image assets.
- The quiz (`#quiz`) shows one question at a time from `QUESTIONS`. `recommend()` maps the answers to a cake and size using `flavorToCake`, `BUDGET_SIZE`, and `BUDGET_CAP`. It steps the size down until the price fits the budget. A wedding with a Vanilla or "Surprise Me" flavor and the `$200+` budget is special-cased to the `wedding` cake. `OCCASION_NOTES` supplies the extra line on the result screen.
- The order form (`#orderForm`) is client-side only. It validates the fields, then hides the form and shows a `#success` summary. Nothing is sent to a server. "Order this cake" buttons in the menu, and the quiz result, both call `prefillOrder()` to fill in the form.
- Pricing rule: price is `cake.price * size.mult`, **except** the `wedding` cake, whose `price` is a fixed total (3 tiers). This exception appears in both `recommend()` and the form submit handler, so keep the two in sync when you change pricing.
- Colors, fonts, radius, and shadow are CSS custom properties on `:root`.
- User-supplied text that goes into `innerHTML` is passed through `escapeHTML`. Keep doing that.

## Skills

`.agents/skills/frontend-design/SKILL.md` is vendored from `anthropics/skills` and pinned in `skills-lock.json` by content hash. Don't edit it by hand. Read it before doing visual or UI design work in this repo. It covers the design-plan-then-critique process and lists the generic "AI-generated" design tells to avoid.
