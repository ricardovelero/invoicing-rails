---
kind: frontend_style
name: Tailwind CSS + Alpine.js Design System
category: frontend_style
scope:
    - '**'
source_files:
    - config/tailwind.config.js
    - app/assets/stylesheets/application.tailwind.css
    - app/assets/stylesheets/application.css
    - app/views/layouts/application.html.erb
    - app/views/layouts/home.html.erb
    - app/views/shared/_head.html.erb
    - config/initializers/simple_form.rb
---

The application uses a Tailwind CSS-first styling approach layered on top of the Rails Sprockets asset pipeline, with Alpine.js for lightweight interactivity and Heroicons for iconography. The system is organized around design tokens in config/tailwind.config.js (custom shadows, typography scale, spacing, breakpoints) and reusable component classes defined in app/assets/stylesheets/application.tailwind.css under @layer components.

Core stack:
- Tailwind CSS v3 — utility-first CSS compiled via Sprockets (stylesheet_link_tag "tailwind"), with @tailwind base/components/utilities directives and a custom @layer components block defining semantic UI primitives.
- Alpine.js — declarative reactivity injected directly into layout ERB (x-data, x-init, :class) for sidebar state persistence and small DOM toggles; [x-cloak] suppression handled in application.css.
- Heroicons — Ruby helper (heroicon) renders SVG icons inline with Tailwind classes passed through options: { class: ... }.
- SimpleForm — default wrapper :fz wraps inputs in a .input container; button defaults to the shared .btn class.
- Inter font — loaded as a separate Sprockets asset (inter-font) and registered as fontFamily.inter in Tailwind.

Design tokens & conventions:
- Typography: custom fontSize scale with tight letter-spacing; heading utilities .h1–.h4 built on top of Tailwind sizes.
- Color palette: indigo (indigo-500/600) as primary action color, slate (slate-50/100/200/400/600/800) for neutrals, rose/green for status badges (.past-due, .paid, .on-time).
- Shadows: extended boxShadow tokens (DEFAULT, md, lg, xl) used consistently across cards and buttons.
- Breakpoints: standard Tailwind defaults plus an extra xs: 480px; responsive headings scoped via @screen md.
- Z-index: custom 60 layer reserved for overlays like modals/sidebars.

Reusable component classes (@layer components):
- Buttons: .btn, .btn-lg, .btn-sm, .btn-xs, .btn-primary, .btn-secondary, .btn-danger, .filter-btn, .filter-btn-active.
- Forms: .form-input, .form-textarea, .form-select, .form-checkbox, .form-radio, .form-switch, .input-label, .required.
- Layout: .sidebar_link, .link_text, .modal, .modal-content, .alert, .notice, .title, .paragraph, .gravatar.
- Tables/lists: .table-td-highlight, .table-td, .list-line-even, .list-line-odd.
- Status badges: .past-due, .not-paid, .on-time, .paid.
- Pagination: full overrides for pagy-nav / pagy-combo-nav-js using Tailwind utilities.

Layout strategy:
- Two layouts: application.html.erb (authenticated app shell with sidebar/navbar/main content area) and home.html.erb (public pages). Both apply font-inter antialiased text-slate-600 and render shared/head which loads Tailwind + Inter font before the app stylesheet.
- Sidebar expanded/collapsed state persisted in localStorage and reflected via Alpine's :class binding and a Tailwind variant sidebar-expanded added through a custom plugin.

Build & delivery:
- Styles are precompiled by Sprockets into public/assets/application.tailwind-*.css and application-*.css; Tailwind scans ERB views, helpers, Stimulus controllers, and vendor JS for class usage via the content glob list.
- A safelist includes form validation classes (border-red-500, text-red-500, ...) so they survive purging when applied dynamically via JavaScript.

Rules developers should follow:
1. Prefer Tailwind utility classes over writing new CSS; only add to @layer components in application.tailwind.css when a pattern repeats across multiple views.
2. Use the existing token set (colors from slate/indigo, shadow names, font family font-inter) rather than ad-hoc values.
3. For icons, use <%= heroicon "name", options: { class: "..." } %> instead of inline SVGs.
4. Build forms with SimpleForm's default :fz wrapper; override via wrapper: :default only when you need the legacy label/hint/error structure.
5. Keep interactive behavior in Alpine.js (x-data, x-show, x-transition) or Stimulus controllers; avoid jQuery or raw event listeners.
6. When adding new responsive variants, extend screens in tailwind.config.js and reference them via @screen or Tailwind's sm:/md: prefixes.