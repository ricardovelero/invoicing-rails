---
kind: configuration_system
name: Rails Configuration System (application.rb, initializers, environments, credentials)
category: configuration_system
scope:
    - '**'
source_files:
    - config/application.rb
    - config/environment.rb
    - config/database.yml
    - config/environments/development.rb
    - config/environments/test.rb
    - config/environments/production.rb
    - config/initializers/devise.rb
    - config/initializers/locale.rb
    - config/initializers/pagy.rb
    - config/initializers/simple_form.rb
    - config/credentials.yml.enc
    - config/storage.yml
    - config/importmap.rb
---

The application uses the standard Rails 7 configuration stack with environment-based overrides and encrypted credentials for secrets.

Boot and defaults
- config/boot.rb pins BUNDLE_GEMFILE to the repo root Gemfile.
- config/application.rb loads rails/all, calls Bundler.require(*Rails.groups), sets config.load_defaults 7.1, enables autoload_lib(ignore: %w[assets tasks]), sets time_zone = 'Madrid', wires Devise mailer layout via config.to_prepare, and raises on missing i18n keys (i18n.raise_on_missing_translations = true).
- config/environment.rb simply requires application and calls Rails.application.initialize!.

Environment-specific settings
- config/environments/development.rb: eager_load false, local error pages, optional dev cache toggle via tmp/caching-dev.txt, Active Storage :local, Letter Opener mailer delivery, verbose query logs, asset debug mode.
- config/environments/test.rb: eager_load only under CI, null cache store, no forgery protection, Active Storage :test, mailer :test delivery, deprecations to stderr.
- config/environments/production.rb: eager_load true, caching enabled, SSL forced, log level :debug, request_id tags, stdout logging when RAILS_LOG_TO_STDOUT is set, Postmark mailer using Rails.application.credentials.postmark_api_token, schema dump disabled after migrations.

Initializers (per-gem configuration)
- devise.rb: authentication strategies, pepper, password stretch per env, email confirmation windows, timeout, reconfirmation, notification toggles.
- locale.rb: adds lib/locales/**/*.{rb,yml} to I18n load path, permits [:es, :en], default locale :es.
- pagy.rb: default items per page 10, loads Spanish and English pagination strings.
- simple_form.rb: custom :fz wrapper as default, hidden labels, Tailwind classes, nested booleans, browser validations off.
- Other initializers wire carmen, heroicon, inflections, CSP, permissions policy, route translator, filter parameter logging, and new framework defaults.

Secrets and sensitive values
- config/credentials.yml.enc + config/master.key: Rails encrypted credentials; production reads postmark_api_token from credentials.
- config/database.yml: PostgreSQL adapter with ERB interpolation of DATABASE_* env vars in production; development/test use hardcoded local user/password.
- Environment variables used at boot/config time: RAILS_MAX_THREADS, DATABASE_URL (commented guidance), RAILS_MASTER_KEY, RAILS_SERVE_STATIC_FILES, RAILS_LOG_TO_STDOUT, CI.

Frontend configuration
- config/importmap.rb pins Turbo, Stimulus, ApexCharts, Alpine.js and auto-pins controllers under app/javascript/controllers.
- config/tailwind.config.js drives Tailwind build.

Conventions developers should follow
- Put gem-wide runtime configuration in config/initializers/<gem>.rb; do not inline it in models or controllers.
- Keep per-environment differences in config/environments/*.rb; keep shared defaults in config/application.rb.
- Store secrets exclusively in config/credentials.yml.enc (accessed via Rails.application.credentials) or via process environment variables; never hardcode passwords or tokens in YAML files committed to git.
- Database connection details for production must come from DATABASE_* env vars as shown in database.yml.
- New feature flags or app-level toggles belong in a dedicated initializer (e.g. config/initializers/my_feature.rb) rather than scattered ENV checks.