---
kind: build_system
name: Rails Sprockets + Tailwind Asset Pipeline with Puma/Render Deployment
category: build_system
scope:
    - '**'
source_files:
    - Gemfile
    - Gemfile.lock
    - package.json
    - pnpm-lock.yaml
    - .ruby-version
    - config/boot.rb
    - config/application.rb
    - config/puma.rb
    - Procfile
    - Procfile.dev
    - bin/dev
    - bin/setup
    - bin/render-build.sh
    - Rakefile
---

This Rails 7.2 application uses a conventional Ruby/Rails build and deployment stack centered on Bundler, the Sprockets asset pipeline (with Tailwind CSS), and Puma as the production web server. There is no Dockerfile or custom CI pipeline in the repository; deployment targets are Render and Heroku-style platforms via Procfile.

Ruby and dependency management:
- Ruby version pinned to 3.3.12 via .ruby-version.
- Gem dependencies declared in Gemfile (Rails 7.2.1, puma 7.2, sprockets-rails, importmap-rails, turbo-rails, stimulus-rails, tailwindcss-rails ~> 2.3, devise, pg_search, pagy, etc.).
- Lockfiles: Gemfile.lock for Ruby gems and pnpm-lock.yaml for JS packages.
- Boot sequence: config/boot.rb sets BUNDLE_GEMFILE, loads bundler/setup, then bootsnap; config/application.rb calls Bundler.require(*Rails.groups) so dev/test/prod groups are loaded automatically.

Asset pipeline:
- CSS: Tailwind via tailwindcss-rails; source lives under app/assets/stylesheets/application.tailwind.css plus config/tailwind.config.js; compiled output goes into public/assets/ (Sprockets manifest present).
- JavaScript: Importmaps (importmap-rails) with Stimulus controllers under app/javascript/controllers/; precompiled bundles shipped in public/assets/.
- Images/static assets live under app/assets/images/ and are fingerprinted by Sprockets.
- No Webpacker/esbuild/vite — the project stays on the classic Sprockets pipeline.

Development workflow:
- bin/dev installs and runs foreman against Procfile.dev, which starts two processes: web: bin/rails server -p 3000 and css: bin/rails tailwindcss:watch.
- bin/setup is idempotent: installs bundler, runs bundle check || bundle install, prepares the database (db:prepare), clears logs/tmp, and restarts the server.
- Development-only tooling includes rubocop, prettier, htmlbeautifier, letter_opener, letter_opener_web, debug, database_cleaner, faker, capybara, selenium-webdriver.

Production runtime:
- Procfile declares web: bundle exec puma -C config/puma.rb.
- config/puma.rb reads concurrency from RAILS_MAX_THREADS / RAILS_MIN_THREADS, port from PORT, environment from RAILS_ENV, and enables the tmp_restart plugin so bin/rails restart works.
- Workers/threading are left at defaults (threaded only, no clustered workers) — suitable for single-process deployments like Render free tiers.

CI and deployment:
- bin/render-build.sh is the Render-specific build hook: it runs bundle install, skips schema load (commented out), precompiles assets (rails assets:precompile), then cleans unused assets (rails assets:clean). Database migrations are expected to run separately in the platform's deploy steps.
- No GitHub Actions, CircleCI, or other CI files are present in the repo.

Rake tasks:
- Rakefile simply requires config/application and delegates to Rails.application.load_tasks; all tasks come from Rails core plus any added under lib/tasks/*.rake (none currently exist).

Conventions developers should follow:
- Keep Ruby gem versions aligned with Gemfile constraints; never edit Gemfile.lock manually.
- Add new CSS through Tailwind classes in views/components; do not hand-write raw CSS outside the Tailwind entry point.
- New JavaScript should be a Stimulus controller wired via Importmaps under app/javascript/controllers/.
- For local development use bin/dev (foreman) rather than running rails server directly, so Tailwind watch stays in sync.
- On Render, rely on bin/render-build.sh for the build step; do not add migration execution there since it is commented out by design.