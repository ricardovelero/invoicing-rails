# Context — Facturacion

Ubiquitous language for this invoicing application. Use these terms as defined here in code, issues, tests, and conversation. Don't drift to synonyms.

## Glossary

### Scope
A user-owned invoice series identified by a **prefix** (e.g. `"A"`, `"R"`). Equivalent to the Spanish legal concept of *serie*. A user has many scopes. Invoices are numbered within a scope, never globally. Code name: `InvoiceSeries`.

### Sequence
A counter inside a Scope. Holds `last_number`. Exactly **one active Sequence per Scope** at any time, enforced by a Postgres partial unique index — never by application code. A new Sequence is opened only by an explicit manual rollover action (close active, open new). Year labels on a Sequence are cosmetic display metadata only; nothing automatic happens at year boundaries. Code name: `InvoiceSequence`.

### Number
The integer identifying an invoice within its Scope. Stored split on the invoice: `series_id` (FK) + `number` (integer). **NULL while the invoice is a Draft.** The display string (`"A-0042"`) is composed at render time from the Scope's prefix and the padded Number — it is never stored.

### Gapless
The numbering invariant: within a Scope, issued Numbers are strictly correlative with no holes (1, 2, 3, …). Required by Spanish invoicing law (RD 1619/2012, Veri*factu). This invariant is why Drafts hold no Number and why reservation happens at issue time inside a single DB transaction.

### Draft
An invoice with status `borrador`. Has **no Number** (`number` IS NULL). Freely editable and freely deletable — carries no fiscal weight. Becomes issued via the explicit Issue transition. Statuses: `borrador` → `pendiente` → `pagada`.

### Issue (verb)
The transition from Draft to issued (`pendiente`). This is the only moment a Number is reserved: lock the Scope's active Sequence row (`SELECT … FOR UPDATE`), increment `last_number`, assign to the invoice, save — all in one transaction. A failed save rolls the counter back; no gap is created. Creating an invoice directly as `pendiente` Issues immediately.

### Issued invoice
An invoice that has left Draft (`pendiente` or `pagada`). Has a Number. **Undeletable** — fiscal integrity requires the correlative chain never develops holes. Errors on issued invoices are corrected by rectifying invoices (future feature, conventionally series `"R"`), never by deletion.

### Rollover
The manual user action that closes a Scope's active Sequence and opens a new one. Only ever one active Sequence per Scope. Not date-driven — Issue always draws from the active Sequence regardless of invoice date.

## Terms to avoid

- ~~Invoice number as a single string~~ — Number is split storage; the formatted string exists only at render.
- ~~Draft number / provisional number~~ — Drafts have no Number, not even a temporary one.
- ~~Automatic yearly reset~~ — Rollover is manual only.
- ~~Delete invoice~~ — only Drafts can be destroyed; say "delete draft" or "rectify".

## Decisions

See `docs/adr/`:

- `0001-invoice-number-sequencing.md` — scoped series, gapless numbering, atomic reservation at issue time, draft lifecycle, migration of legacy numbers.
