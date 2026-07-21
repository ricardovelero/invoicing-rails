---
kind: dependency_management
name: Ruby and JavaScript Dependency Management with Bundler and pnpm
category: dependency_management
scope:
    - '**'
source_files:
    - Gemfile
    - Gemfile.lock
    - package.json
    - pnpm-lock.yaml
    - config/importmap.rb
    - .ruby-lsp/Gemfile
---

This Rails application manages dependencies through two separate, complementary systems: Ruby gems via Bundler and JavaScript packages via pnpm, with Importmap handling runtime resolution of frontend assets.

## Ruby Dependencies (Bundler)
- Manifest: Gemfile declares all Ruby gems against the https://rubygems.org source with a pinned Ruby version (~> 3.3) and Rails (~> 7.2.1).
- Lockfile: Gemfile.lock pins every transitive dependency to exact versions, ensuring reproducible installs across environments.
- Grouping: Gems are organized into groups — development, test, and shared top-level declarations — for dev tooling (rubocop, web-console, letter_opener), testing (capybara, selenium-webdriver, database_cleaner, faker), and production runtime (devise, tailwindcss-rails, pg, puma).
- Runtime vs. Dev: Production-critical gems (devise, simple_form, pagy, postmark-rails, receipts, heroicon, carmen, route_translator, requestjs-rails, premailer-rails, wicked) live at the top level; development-only tooling is isolated in groups so they are not installed on CI/production.
- Ruby LSP workspace: .ruby-lsp/Gemfile evaluates the root Gemfile and adds ruby-lsp and ruby-lsp-rails as development-only extras for editor integration.

## JavaScript Dependencies (pnpm + Importmap)
- Package manifest: package.json declares only one direct npm dependency (tailwindcss-stimulus-components ^3.0.4) and sets the package manager to pnpm@10.30.3.
- Lockfile: pnpm-lock.yaml pins the full dependency tree (including the peer dep @hotwired/stimulus@3.2.2) with integrity hashes, guaranteeing deterministic installs.
- Runtime pinning: config/importmap.rb uses pin directives to resolve each JS module to a specific file or CDN URL (e.g., apexcharts@3.36.3, alpinejs@3.10.5, alpine-turbo-drive-adapter@2.0.0 from ga.jspm.io). This decouples runtime loading from the build step and lets the app load ESM modules directly in the browser without a bundler.
- Stimulus controllers: pin_all_from "app/javascript/controllers", under: "controllers" auto-registers local Stimulus controllers by filename, keeping feature-scoped JS colocated with views.

## Build-time Asset Pipeline
- The Sprockets pipeline (via sprockets-rails and tailwindcss-rails) compiles CSS/JS into fingerprinted files under public/assets/. These built artifacts are what Importmap ultimately serves at runtime.
- Prebuilt vendor bundles (turbo.min.js, stimulus.min.js, etc.) ship alongside the app's own compiled output.

## Conventions and Rules
- Pin major/minor versions in Gemfile using ~> constraints; never leave gem versions completely unbounded.
- Commit both Gemfile.lock and pnpm-lock.yaml to keep CI and production builds identical to development.
- Keep runtime gems at the top level of the Gemfile; move development/testing-only tools into their respective groups.
- Use bin/importmap (provided by importmap-rails) to add new JS pins rather than editing config/importmap.rb by hand.
- Do not commit generated lockfiles from IDEs or editors (the .ruby-lsp/Gemfile header explicitly warns against committing it despite being present here).
- Prefer Importmap pins over npm-installed node_modules when possible, since the app does not use a Node-based bundler.