---
kind: external_dependency
name: Postmark email delivery service
slug: postmark
category: external_dependency
category_hints:
    - vendor_identity
scope:
    - '**'
---

### Postmark
- Role: production ActionMailer delivery backend for all outbound emails (confirmation, invoice PDFs, etc.).
- Integration point: `config.action_mailer.delivery_method = :postmark` with the API token read from `Rails.application.credentials.postmark_api_token`.
- Development fallback: `letter_opener` / `letter_opener_web` is mounted at `/letter_opener` to preview mail locally; this route is currently unguarded and visible in production unless environment-scoped.
- Verify exact credential key shape against official docs.