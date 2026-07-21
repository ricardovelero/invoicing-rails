---
kind: external_dependency
name: Render hosting platform
slug: render
category: external_dependency
category_hints:
    - vendor_identity
scope:
    - '**'
---

### Render
- Role: production host for the app. The default URL options are hard-coded to `invoicing-rails.onrender.com`, indicating a Render-hosted web service.
- Implication: secrets (DB credentials, Postmark token) are expected via environment variables or Render's secret store rather than checked-in files.