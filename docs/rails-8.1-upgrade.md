# Rails 8.1.3.1 upgrade

Date: 2026-09-16. Scope: Rails 8.0.5.1 → 8.1.3.1 only.

## Baseline established before application changes

- Ruby **3.3.12p206**, Bundler **2.4.10**, Rails **8.0.5.1**; clean working tree.
- Preserve `ruby '~> 3.3'`, `.ruby-version`, `config.load_defaults 8.0`, and
  `tailwindcss-rails ~> 2.3` (the existing Tailwind CSS v3 toolchain).
- PostgreSQL, Sprockets, Import Maps, Turbo, Stimulus, Devise, Simple Form,
  Route Translator, Postmark and Render/Puma remain the existing integration.
- Jobs use the implicit async adapter; sessions use CookieStore; production
  cache uses FileStore. Disk storage is configured but no app attachments exist.
  Cable has only the base classes; the unused production Redis configuration
  without a Redis gem is a pre-existing concern, outside this migration.
- Unmodified `bin/ci` passed: database preparation, Zeitwerk, Tailwind build,
  **13 RSpec examples**, **128 Minitest tests / 335 assertions**, and
  **4 Chrome system tests / 11 assertions**, without failures or skips.
- Development boot, production eager boot against `invoicing_test`, and
  production asset precompilation passed.
- Full RuboCop: **159 files, 809 existing offenses**, exit 1.
- Brakeman 8.0.6, installed only in `/private/tmp/rails81-tool-gems`:
  **2 existing weak warnings**, no scanner errors, exit 3. These concern Rails
  8.0 support ending and HEAD/GET handling in `ApplicationController`.
- Existing informational warnings: excluded mailer previews during Zeitwerk,
  outdated bundled Browserslist data, and Prawn's limited built-in Unicode fonts.
  No Rails deprecations occurred; test configuration already raises on them.
- Complete baseline output: `tmp/rails81-baseline-{ci,rubocop,brakeman,assets,
  development-boot,production-boot}.log` and the Brakeman JSON report.

## Migration plan, established before dependency changes

1. Pin Rails exactly to **8.1.3.1**. Resolve using the unchanged Bundler 2.4.10
   with `bundle update rails --conservative`. Expect the Rails component gems
   to move together; allow another gem change only if a new framework constraint
   or demonstrated incompatibility requires it. Compare all versions against
   the original lockfile and preserve existing Darwin/Linux platforms.
2. Keep **all Rails 8.0 defaults** and existing environment/initializer settings.
   Review exact-version Rails configuration/template differences and upgrade
   guidance; use `app:update` only if it helps resolve a required configuration
   change. Do not generate replacement configuration or introduce 8.1 defaults.
3. Audit actual usages against removed/deprecated APIs. Static reconnaissance
   found no app bulk writes, custom job serializers, signed IDs, problematic
   finder-order configuration, attachment workflows, or Rails monkey patches.
   Existing Madrid/DST, PostgreSQL dates, invoice transaction/numbering, Devise
   sessions, JSON/PDF, localization, forms and Turbo tests cover relevant behavior.
4. Prioritize boot/routes, Route Translator's mapper integration, Sprockets and
   form helpers, Devise/Responders, and `pg_search`. Do not upgrade old gems merely
   because they use internals; require a documented or observed incompatibility.
5. After resolution, run boot and focused compatibility specs first. Classify
   failures before changing application code. Run full `bin/ci` with CI eager
   loading, RuboCop, the same isolated Brakeman, production precompile, all three
   environment boots, and read-only database migration status.
6. Compare warnings with baseline, preserving deprecation errors. Review every
   changed file and dependency; reject unrelated schema, formatting, frontend,
   Ruby, CI, deployment or generated churn. Do not commit or push.

Independent read-only agents established the inventory and official-source
compatibility audit. A separate inventory-agent review challenges this plan;
the lead owns dependency/configuration decisions and final diff review.

### Plan challenge and decision

Exact Rails gemspec review identifies one new framework dependency,
`action_text-trix ~> 2.1.15`, and Active Support replacing its `benchmark`
dependency with `json` (already locked at 2.7.1). These are justified framework
dependency changes; all existing unrelated versions should remain locked.
Initial source review justified no application/configuration rewrite. Validate effective
defaults after boot as well as `load_defaults`, and compare individual lint and
security findings. The parser audit found an unused `old.html.erb` template with
leading-bracket names; active registration forms do not use it. Preserve that
unused template. The application's sort helper uses query serialization;
inspect that behavior and preserve parsed sorting/filter parameters. The local
PostgreSQL 18.6 exceeds Rails 8.1's 9.5 minimum; the deployed version needs a
separate environment check. No migration or production-data change is needed.

### Runtime finding and narrow compatibility decision

The first full target-version CI run passed RSpec but failed the existing
clients-edit Minitest on a Rails deprecation. The complete stack and minimal
country-lookup reproduction locate `mb_chars` inside Carmen 1.1.3's private
`normalise_name`, reached through `ApplicationRecord#country_code`; this is a
category **B** gem issue, not an application call to the deprecated API.
Fresh upstream/RubyGems inspection found no newer release, and upstream master
still uses the deprecated call. Upgrading Carmen or changing its source would
not fix it. A patch is warranted to preserve country-name lookup and strict
deprecation checks without changing country data or introducing a replacement.

The existing Carmen initializer overrides only that private method with native
String downcasing and NFKC normalization. It retains the old proxy's UTF-8
coercion, case-insensitive matching, and operation order. No warning is silenced.
An independent agent reviewed the original proxy and matching semantics. A
regression in the existing framework spec first failed on the exact deprecation;
it exercises English/Spanish country names, uppercase/decomposed/fullwidth
Unicode, UTF-8 bytes tagged as binary, alpha-2 codes, nil and unknown names.

## Completion report

### Runtime and dependencies

- Ruby before/after: **3.3.12p206**, arm64-darwin25. Neither the Ruby constraint
  nor `.ruby-version` changed. Ruby 4 was not used.
- Rails: **8.0.5.1 → 8.1.3.1**.
- Bundler before/after: **2.4.10**; lockfile Bundler/Ruby metadata and all four
  existing Darwin/Linux platforms are unchanged.

Every changed gem entry:

| Gem | Before | After | Why |
| --- | --- | --- | --- |
| `rails` | 8.0.5.1 | 8.1.3.1 | Requested framework target |
| `actioncable` | 8.0.5.1 | 8.1.3.1 | Exact Rails component requirement |
| `actionmailbox` | 8.0.5.1 | 8.1.3.1 | Exact Rails component requirement |
| `actionmailer` | 8.0.5.1 | 8.1.3.1 | Exact Rails component requirement |
| `actionpack` | 8.0.5.1 | 8.1.3.1 | Exact Rails component requirement |
| `actiontext` | 8.0.5.1 | 8.1.3.1 | Exact Rails component requirement |
| `actionview` | 8.0.5.1 | 8.1.3.1 | Exact Rails component requirement |
| `activejob` | 8.0.5.1 | 8.1.3.1 | Exact Rails component requirement |
| `activemodel` | 8.0.5.1 | 8.1.3.1 | Exact Rails component requirement |
| `activerecord` | 8.0.5.1 | 8.1.3.1 | Exact Rails component requirement |
| `activestorage` | 8.0.5.1 | 8.1.3.1 | Exact Rails component requirement |
| `activesupport` | 8.0.5.1 | 8.1.3.1 | Exact Rails component requirement |
| `railties` | 8.0.5.1 | 8.1.3.1 | Exact Rails component requirement |
| `action_text-trix` | Absent | 2.1.19 | New mandatory Action Text `~> 2.1.15` dependency |
| `benchmark` | 0.5.0 | Removed | Active Support removed the dependency; no remaining locked dependency uses it |

Active Support now depends on `json`; the existing **2.7.1** satisfies it and
remains unchanged. All other gem versions, including Carmen 1.1.3 and the entire
frontend toolchain, remain unchanged. Brakeman 8.0.6 and its temporary `racc`
installation are isolated validation tools and are not application dependencies.

### Configuration, code and deprecations

The only configuration file changed is `config/initializers/carmen.rb`: its
existing inclusion remains, and the localized private-method override replaces
the demonstrated deprecated call. No models, controllers, views, environment
settings, migrations, schema, deployment files, CI files or frontend files changed.
`spec/models/framework_compatibility_spec.rb` adds the country-lookup regression.
The two new documents record the required plan, audit and completion evidence.

`app:update` was not run: exact-version generator/template comparison found only
optional/new-application changes and a defaults initializer deliberately outside
scope. Preserving existing configuration required no generated replacement.

| Class | Observed finding | Resolution |
| --- | --- | --- |
| A — application compatibility | No direct deprecated application API found | No application-model/controller rewrite |
| B — third-party code | Carmen `querying.rb:48`, `String#mb_chars`, reached by client editing and country lookup | Native normalization override, regression and baseline comparison; no available upstream release |
| C — deferred defaults | No warning observed from retained defaults | All 8.1 opt-in defaults remain deferred |
| D — pre-existing/unrelated | Browserslist data, Prawn PDF fonts, excluded mailer previews, installed `stringio` metadata ambiguity during Bundler; existing missing translations found in extra URL smoke checks | Recorded; no suppression or unrelated updates |

The first target CI failure and the initial focused regression failure are
retained in `tmp/rails81-first-final-ci.log` and
`tmp/rails81-carmen-regression-before.log`. A preliminary fullwidth assertion
was corrected to call `Country.named` directly: the application's existing
ASCII-letter heuristic intentionally bypasses named lookup for that input.
That existing behavior was preserved. The first temporary defaults-check
assertion also needed to interpret an unset tracker setting as the effective
regex tracker, as the exact Rails dependency-tracker source does; no application
configuration change was necessary.

No Rails deprecations occurred in the final suite; test configuration still raises
on every Rails deprecation. Development logging and the existing production
deprecation policy are unchanged.

Effective old defaults were verified after eager boot in all three environments:

| Setting | Retained value | Deferred 8.1 value |
| --- | --- | --- |
| `config.load_defaults` | 8.0 | 8.1 |
| `action_controller.escape_json_responses` | true | false |
| `active_support.escape_js_separators_in_json` | true | false |
| `action_controller.action_on_path_relative_redirect` | :log | :raise |
| `active_record.raise_on_missing_required_finder_order_columns` | false | true |
| Action View dependency tracker | Regex/ERB tracker | Ruby tracker |
| `action_view.remove_hidden_field_autocomplete` | false | true |
| `yjit` | true in all three environments, inherited from 7.2 defaults | Disabled in development/test |

HTML entity escaping also remains enabled. A JSON sample containing `<>&` and
Unicode line/paragraph separators encoded to identical bytes before/after.
Environment snapshots confirm unchanged Madrid timezone, Ruby/Bundler, storage,
sessions/cookie serializer, mail, job and cache adapters. Tests select the test
job adapter automatically, as before; development/production retain async jobs.

### Exact validation commands and results

Commands ran from the repository root under Ruby 3.3.12. Output is preserved in
ignored `tmp/rails81-*` files; safe production checks override the database to
`invoicing_test` and use a dummy boot secret. No production data was accessed,
no migrations were applied, and no external deliveries or jobs were invoked.

| Exact command | Result |
| --- | --- |
| `ruby -v`; `bundle -v`; `bundle exec rails --version`; `bundle check` | Baseline 3.3.12 / 2.4.10 / 8.0.5.1; final 3.3.12 / 2.4.10 / 8.1.3.1; dependency check passes |
| `RBENV_VERSION=3.3.12 RAILS_ENV=test rbenv exec ruby -e 'exec("/bin/bash", "bin/ci")'` | Unchanged baseline passes: 13 RSpec, 128 Minitest / 335 assertions, 4 Chrome / 11 assertions |
| `bundle exec rubocop` | Baseline exit 1: 159 files / 809 existing offenses |
| `RAILS_ENV=development bin/rails runner 'puts "BOOT #{Rails.env} Rails #{Rails.version} Ruby #{RUBY_VERSION} defaults=#{Rails.application.config.loaded_config_version}"'` | Baseline development boot passes |
| `RAILS_ENV=production DATABASE_URL=postgresql:///invoicing_test SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile` | Both baseline and final pass; final output `tmp/rails81-final-assets.log` |
| `RAILS_ENV=test bin/rails db:migrate:status` | Both baseline and final pass; all migrations up |
| `RBENV_VERSION=3.3.12 bundle update rails --conservative` | Passes; only the justified 15 changed/added/removed gem entries above |
| `RBENV_VERSION=3.3.12 RAILS_ENV=test bundle exec rspec spec/models/framework_compatibility_spec.rb spec/requests/rails_upgrade_spec.rb` | Initial existing 13 examples pass before full CI reveals Carmen path |
| `RAILS_ENV=test bin/rails runner 'puts Country.named("España")&.alpha_2_code'` | Before fix, exit 1 reproduces the Carmen deprecation with its full stack |
| `RAILS_ENV=test bundle exec rspec spec/models/framework_compatibility_spec.rb --example 'country-name'` | Before fix, exit 1 on the exact Carmen deprecation |
| `RAILS_ENV=test bundle exec rspec spec/models/framework_compatibility_spec.rb spec/requests/rails_upgrade_spec.rb` | After fix, 14 examples / 0 failures |
| `RBENV_VERSION=3.3.12 RAILS_ENV=test CI=1 rbenv exec ruby -e 'exec("/bin/bash", "bin/ci")'` | First run exposes Carmen; final rerun exit 0: 14 RSpec, 128 Minitest / 335 assertions, 4 Chrome / 11 assertions; no failures/errors/skips |
| `BUNDLE_GEMFILE="$PWD/tmp/rails81-baseline-Gemfile" bundle exec rubocop --cache false --format json --out tmp/rails81-baseline-rubocop.json` | Baseline exit 1; structured offense baseline |
| `bundle exec rubocop --cache false --format json --out tmp/rails81-final-rubocop.json` | Final exit 1; same 159 files / 809 offenses, every offense identity/location/message unchanged |
| `GEM_HOME=/private/tmp/rails81-tool-gems GEM_PATH=/private/tmp/rails81-tool-gems ruby /private/tmp/rails81-tool-gems/gems/brakeman-8.0.6/bin/brakeman --no-pager --format json --output tmp/rails81-baseline-brakeman.json` | Baseline exit 3: 2 weak warnings, no scanner errors |
| Same Brakeman command with `--output tmp/rails81-final-brakeman.json` | Final exit 3: 1 unchanged weak HEAD/GET warning; Rails-support warning removed; no new fingerprints/errors |
| `RAILS_ENV=development DATABASE_URL=postgresql:///invoicing_test bin/rails runner tmp/rails81-runtime-check.rb` | Eager boot and retained effective settings pass |
| `RAILS_ENV=test DATABASE_URL=postgresql:///invoicing_test CI=1 bin/rails runner tmp/rails81-runtime-check.rb` | Eager boot and retained effective settings pass |
| `RAILS_ENV=production DATABASE_URL=postgresql:///invoicing_test SECRET_KEY_BASE_DUMMY=1 bin/rails runner tmp/rails81-runtime-check.rb` | Eager boot and retained effective settings pass; Postmark configured but no deliveries |
| Each of the preceding three commands prefixed with `BUNDLE_GEMFILE="$PWD/tmp/rails81-baseline-Gemfile"` | Original runtime snapshots pass; existing settings and JSON bytes compare equal |
| `RAILS_ENV=development bin/rails db:migrate:status` | Final read-only status passes; all migrations up |
| `BUNDLE_GEMFILE="$PWD/tmp/rails81-baseline-Gemfile" RAILS_ENV=test bin/rails runner tmp/rails81-country-snapshot.rb`; `RAILS_ENV=test bin/rails runner tmp/rails81-country-snapshot.rb` | Identical results for 498 English/Spanish country/locale pairs and 1,494 name/case/decomposition/encoding variants |
| `PATH="/Users/ricardorodriguez/.rbenv/versions/3.3.12/bin:$PATH" RBENV_VERSION=3.3.12 RAILS_ENV=test DATABASE_URL=postgresql:///invoicing_test BUNDLE_GEMFILE="$PWD/tmp/rails81-baseline-Gemfile" bundle _2.4.10_ exec bin/rails runner tmp/rails81-sort-url-check.rb` | Baseline exit 0; records 30 sorting/filter cases |
| `PATH="/Users/ricardorodriguez/.rbenv/versions/3.3.12/bin:$PATH" RBENV_VERSION=3.3.12 RAILS_ENV=test DATABASE_URL=postgresql:///invoicing_test BUNDLE_GEMFILE="$PWD/Gemfile" bundle _2.4.10_ exec bin/rails runner tmp/rails81-sort-url-check.rb` | Final exit 0; all 30 case arrays match exactly, including 48 successful GET snapshots and 12 pre-existing translation failures |
| `bundle platform` | Ruby requirement satisfied; existing Darwin and x86_64 Linux platforms retained |
| `git diff --check`; `git diff`; `git status --short` | No whitespace errors; lead reviews every changed file and confirms scope |

`bin/ci` executes the exact CI checks: `CI= bin/rails db:test:prepare`,
`bin/rails zeitwerk:check`, `bin/rails tailwindcss:build`, `bundle exec rspec`,
`bin/rails test`, and `bin/rails test:system`. Import Maps requires no JavaScript
bundle build; production Sprockets precompilation validates the existing JS/CSS
assets. No package dependency or script was changed. Local PostgreSQL is **18.6**,
Chrome **153.0.8010.36**; the checked-in CI targets PostgreSQL 16 on Ubuntu.
Actual remote CI was not triggered because nothing was committed or pushed.

The initial sandbox PostgreSQL/cache/network restrictions and rbenv's inability
to dispatch Bash/bin/ci directly were environmental. Approved local exceptions,
an isolated tool directory, and the Ruby-to-Bash launcher resolved them without
application changes.

### Remaining concerns and deployment assessment

The framework migration is validated for deployment review with Rails 8.0
defaults. Functional checks pass; the complete quality tools retain the known
baseline failures (809 lint offenses and one weak Brakeman finding), so this is
not a claim that the repository has a clean lint/security baseline.

The Carmen override is the remaining explicit compatibility measure; remove it
only after a verified upstream fix and the regression pass. No additional
third-party upgrade is justified on exercised paths. Mail has an unused legacy
multibyte helper in its source; no warning appeared on actual app mail paths.
Unused production Cable Redis configuration, production database `hostname`,
and the inactive legacy registration template remain pre-existing concerns.

Additional sort/filter comparisons reproduce two unrelated missing-translation
errors on both Rails versions: `en.borrar_item` in the English item index, and
`es.imagen_busqueda` in the search-not-found partial. They are documented
pre-existing application failures; this upgrade does not change translations or
weaken strict translation checks. The actual helper emits identical sorting
URLs for ordinary, blank and nil filter cases: Rails routing removes nil values
before query serialization, so the framework's new `nil.to_query` encoding does
not alter the exercised application links.

Final URL-comparison runs enabled PostgreSQL read-only transactions and Warden's
`:fetch` event. Earlier harness runs updated only disposable test-user sign-in
counters; no production or development records were written.

Before production rollout, confirm the deployed PostgreSQL is ≥ 9.5 and that
the existing Render Ruby 3.3.12/secret/database/mail settings are intact. After
deploying, smoke-test login/session continuity, country selection/client editing,
invoice issuance/numbering/PDF, localization, assets and Turbo navigation. These
checks validate the real deployment environment; local production boot used
only the test database. No production migration is required by this change.
Rollback is the prior Rails 8.0.5.1 dependency/configuration artifact; no data or
schema migration needs reversal. Nothing is staged, committed, pushed or deployed.

### Final diff

`git diff --stat` (tracked files):

```text
 Gemfile                                     |   2 +-
 Gemfile.lock                                | 114 ++++++++++++++--------------
 config/initializers/carmen.rb               |  10 +++
 spec/models/framework_compatibility_spec.rb |  24 ++++++
 4 files changed, 93 insertions(+), 57 deletions(-)
```

Two new untracked documents are additionally present:
`docs/rails-8.1-upgrade.md` (this plan/report) and
`docs/rails-8.1-compatibility-audit.md` (official-source research). Git's unstaged
diff statistics do not include untracked documents. Generated assets, logs,
temporary validation scripts and reports remain ignored.
