# Handoff — Dark Theme, Step 2 (palette research → design-token spike)

> Paste-in prompt for a fresh agent continuing the dark-theme work on the
> `invoicing-rails` app. Self-contained: no prior session context assumed.

---

## Your task

Do **Step 2** of adding a dark theme, in this order:

- **(b) FIRST — get real palette values.** Research Cruip **Mosaic Pro**'s actual
  dark-mode palette (backgrounds, card/surface, border, muted text, foreground,
  primary accent). We are matching the Mosaic look, **not** shadcn defaults.
- **(a) THEN — token spike.** Implement a semantic design-token system (shadcn v3
  pattern) and prove it on ONE screen. Do **not** migrate the whole app yet.

Keep **light mode visually pixel-unchanged**. This is a spike + palette capture,
not the full rollout.

---

## Project context

- **App:** Rails 8 invoicing app (`Facturación iO`), Spanish invoicing compliance.
- **Theme:** hand-ported **ERB** recreation of Cruip **Mosaic Lite**'s look
  (NOT the React template). Reference: https://cruip.com/demos/mosaic/ and
  https://github.com/cruip/tailwind-dashboard-template (Mosaic Lite, React).
- **CSS:** Tailwind **v3.4.1** via `tailwindcss-rails` 2.3.0 (standalone CLI).
  -> Use v3 wiring (`theme.extend.colors` + `<alpha-value>`), **not** v4 `@theme`.
- **Frontend:** Hotwire + Stimulus, importmap (no bundler), ApexCharts 3.36.3.
- **Ruby:** rbenv 3.3.12. `bin/rails` works (shims active).
- **Workspace:** `/Users/ricardorodriguez/Web/invoicing-rails`
- **Branch:** `feature/dark-theme` (Step 1 changes present, **not yet committed**).

---

## Step 1 — ALREADY DONE (do not redo; build on it)

Dark-mode *mechanism* is wired and verified. Files:

- `config/tailwind.config.js` — added `darkMode: "class"`.
- `app/javascript/controllers/theme_controller.js` — **new**. Toggles `dark` class
  on `<html>`, persists `"dark"`/`"light"` to `localStorage["theme"]`, mirrors
  state to button `aria-pressed`. Does **not** write to storage on `connect`
  (first-time visitors follow OS `prefers-color-scheme`). `localStorage` wrapped
  in `try/catch` (private-mode Safari).
- `app/javascript/controllers/index.js` — registers the `theme` controller.
- `app/views/shared/_head.html.erb` — pre-paint FOUC script: reads
  `localStorage["theme"]`, else `prefers-color-scheme`, adds `dark` to
  `<html>` before CSS loads.
- `app/views/shared/_navbar.html.erb` — moon/sun toggle button via `heroicon` gem
  (`variant: :mini`), icons swapped with `dark:hidden` / `hidden dark:block`.
- `config/locales/shared/sidebar/{es,en}.yml` — added `modo_oscuro` label.

**Verified:** `bin/rails tailwindcss:build` OK; compiled CSS contains
`.dark .dark\:hidden`, `.dark .dark\:block`, `.dark .dark\:bg-slate-700`, etc.
(-> the class pipeline works end-to-end).

**Key fact:** the `@layer base { .dark { … } }` token block keys off the **same**
`.dark` class the toggle already adds. Step 1 is fully compatible with tokens —
nothing is wasted.

---

## Why tokens (decision already made)

Palette is highly concentrated, so ~12–14 semantic tokens cover ~90% of usage.
Frequency data from the codebase:

```
text-white 57 · text-slate-400 54 · text-slate-800 48 · border-slate-200 46
text-indigo-500 45 · bg-white 39 · text-slate-500 37 · bg-indigo-500 28
text-indigo-600 24 · text-gray-900 20 · bg-indigo-600 18 · text-slate-600 17
border-slate-300 17 · (status: red/rose/green/yellow tail)
```

- ~40 `@apply` component rules live in `app/assets/stylesheets/application.tailwind.css`.
- ~311+ color-utility instances across **48 of 85** view files.

**Hybrid strategy:** tokens for the ~90% core (surfaces, text, borders, indigo
primary); keep `dark:` variants ONLY for genuine one-offs (decorative gradients
like `from-slate-200 to-slate-100`, a couple of hover states).

---

## Step 2(b) — Palette research deliverable

Produce a concrete token table with **Mosaic-accurate** values as HSL channels
(space-separated, e.g. `210 40% 96%`) for **both** `:root` (light) and `.dark`.

Sources to try, in order: Mosaic Pro demo/source (paid — may be inaccessible),
Mosaic Lite repo dark tokens, else derive from Tailwind **slate** to match
Mosaic's known light look (body `slate-100`, cards `white`, text `slate-600/800`,
borders `slate-200`, sidebar `slate-800`, accent `indigo-500/600`).

Expected dark surfaces (slate-based, adjust to real Mosaic values):
body ~ `slate-900`, card ~ `slate-800`, border ~ `slate-700`,
muted-foreground ~ `slate-400`, foreground ~ `slate-100/200`.

Token vocabulary to fill:
```
background, foreground
card, card-foreground
muted, muted-foreground
border, input, ring
primary, primary-foreground        (indigo)
secondary, destructive
success, warning                   (status pills: paid / past-due / on-time)
```

WARNING: **Do NOT use shadcn's default dark values** (`222.2 84% 4.9%` bg,
`210 40% 98%` fg) — those are shadcn's, they will look wrong on a Mosaic app.

---

## Step 2(a) — Token spike implementation

1. In `app/assets/stylesheets/application.tailwind.css`, after the `@tailwind`
   directives, add:
   ```css
   @layer base {
     :root { --background: 210 40% 96%; --foreground: …; /* … */ }
     .dark { --background: 222 47% 11%; --foreground: …; /* … */ }
   }
   ```
2. In `config/tailwind.config.js` -> `theme.extend.colors`, map each token:
   ```js
   colors: {
     background: "hsl(var(--background) / <alpha-value>)",
     foreground: "hsl(var(--foreground) / <alpha-value>)",
     // …card, muted, border, primary, etc.
   }
   ```
   (The `<alpha-value>` slot is required so `bg-background/50` opacity works.)
3. Convert the **~40 `@apply` component rules** in `application.tailwind.css`
   from concrete colors to semantic utilities (e.g. `bg-white`->`bg-card`,
   `text-slate-800`->`text-foreground`, `border-slate-200`->`border-border`).
   Biggest payoff / lowest risk — do this first.
4. Prove on **ONE screen** (navbar + dashboard): light mode unchanged, dark mode
   looks like Mosaic. `bin/rails tailwindcss:build`, then run `bin/dev` and toggle.

**Do NOT** migrate the 48 view files yet — that's Step 3+.

---

## Gotchas to carry forward

- **Light-mode parity:** tokenizing collapses near-duplicate text colors
  (`text-slate-800` vs `text-gray-900` vs `text-slate-700`) into one token.
  Verify the existing light look does not drift.
- **HSL syntax:** space-separated channels, **no commas**; wire with
  `<alpha-value>` for opacity modifiers.
- **Charts:** ApexCharts does NOT read CSS vars. Read tokens via
  `getComputedStyle(document.documentElement).getPropertyValue('--foreground')`
  etc., and re-apply on toggle (the chart must react to a runtime theme switch,
  not just on load).
- **CSP:** fully commented out in `config/initializers/content_security_policy.rb`
  -> inline scripts are allowed.
- **Built CSS is gitignored** (`app/assets/builds/tailwind.css`); regenerate with
  `bin/rails tailwindcss:build`. Don't commit it.
- **Verification patterns that work here:**
  - ERB syntax -> ActionView Erubi: `bin/rails runner` compiling
    `ActionView::Template::Handlers::ERB::Erubi.new(src).src` via
    `RubyVM::InstructionSequence.compile`.
  - ESM JS syntax -> `node --input-type=module --check < file.js`.
  - YAML -> `ruby -ryaml -e 'YAML.load_file(...)'`.
- **System tests** driving headless Chrome must run OUTSIDE the sandboxed shell.

---

## Suggested skills for the next agent

- **`research`** — for Step 2(b): pull Mosaic Pro/Lite dark palette from primary
  sources and capture findings as a Markdown file.
- **`prototype`** — for Step 2(a): throwaway spike to sanity-check token values
  and the dark look before committing to numbers.
- **`implement`** — later, for the Step 3+ rollout across the 48 view files once
  the token vocabulary is proven.
- **`code-review`** — after the spike, to check light-mode parity and consistency.

---

## Definition of done for Step 2

- [ ] A token table with Mosaic-accurate HSL values for `:root` and `.dark`.
- [ ] `@layer base` token block + `tailwind.config.js` color mapping in place.
- [ ] `@apply` component layer converted to semantic tokens.
- [ ] One screen (navbar + dashboard) verified: light unchanged, dark = Mosaic-like.
- [ ] `bin/rails tailwindcss:build` clean; ERB/YAML/JS checks pass.
- [ ] Charts still render acceptably (or a documented follow-up for token-aware charts).
