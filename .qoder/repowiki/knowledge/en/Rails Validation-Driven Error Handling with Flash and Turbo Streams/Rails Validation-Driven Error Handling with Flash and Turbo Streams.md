---
kind: error_handling
name: Rails Validation-Driven Error Handling with Flash and Turbo Streams
category: error_handling
scope:
    - '**'
source_files:
    - app/controllers/application_controller.rb
    - app/controllers/concerns/current_invoice.rb
    - config/initializers/form_errors.rb
    - app/views/layouts/_alert.html.erb
    - app/views/shared/_flash.html.erb
    - public/404.html
    - public/500.html
    - app/controllers/clients_controller.rb
    - app/controllers/invoices_controller.rb
    - app/controllers/items_controller.rb
---

This Rails application uses a validation-driven error handling approach centered on Active Record validations, HTTP status codes, flash messages, and Turbo Stream responses. There is no custom exception hierarchy or centralized rescue_from middleware — errors are handled locally in controllers using standard Rails patterns.

**Validation and response flow:**
- Controllers follow the `save?` pattern: on success they render JSON with `status: :created`/`:ok`, on failure they re-render the form with `status: :unprocessable_entity` and include `@model.errors` in the JSON payload (e.g., `clients_controller.rb`, `invoices_controller.rb`, `items_controller.rb`).
- HTML responses re-render the new/edit template; Turbo Stream responses set `flash.now[:success]` via `format.turbo_stream { flash.now[:success] = I18n.t('...') }` so the flash partial renders inline without a redirect.
- The `after_register_controller.rb` uses `render_wizard @user, status: :unprocessable_entity` to surface multi-step registration validation failures.
- A single explicit `rescue ActiveRecord::RecordNotFound` appears in `app/controllers/concerns/current_invoice.rb`, falling back to creating a new invoice when the session-stored one is missing.

**User-facing feedback:**
- Flash notices/alerts are rendered through two helpers: `app/views/layouts/_alert.html.erb` (persistent `notice`/`alert`) and `app/views/shared/_flash.html.erb` (auto-dismissing Alpine.js toast for all flash keys).
- Form field-level errors are styled globally via `config/initializers/form_errors.rb`, which wraps invalid inputs with Tailwind red border classes and injects a `<p>` containing `instance.error_message.join(', ').humanize` beneath each input/select/textarea.

**HTTP-level defaults:**
- `public/404.html` and `public/500.html` use Rails' default static error pages.
- `protect_from_forgery with: :exception` in `ApplicationController` lets Rails raise `ActionController::InvalidAuthenticityToken` for CSRF mismatches rather than silently failing.
- No custom `rescue_from` declarations exist in `ApplicationController`; unhandled exceptions bubble to Rails' default exception app.

**Conventions developers should follow:**
- Prefer model validations over manual `raise` statements; return `status: :unprocessable_entity` and include `@record.errors` in JSON responses.
- For Turbo Stream endpoints, use `flash.now[:success]` / `flash.now[:error]` instead of redirects so the client-side partial updates in place.
- Use `rescue ActiveRecord::RecordNotFound` only for recoverable lookups (like the session-backed invoice); do not swallow other exceptions.
- Keep user-visible messages in i18n keys referenced from flash/Turbo responses rather than hardcoding strings.