# Context — Facturacion

Ubiquitous language for this invoicing application. Use these terms as defined here in code, issues, tests, and conversation. Don't drift to synonyms.

## Glossary

### Scope
A user-owned invoice series identified by a **prefix** (e.g. `"A"`, `"R"`). Equivalent to the Spanish legal concept of *serie*. A user has many scopes. Invoices are numbered within a scope, never globally. Code name: `InvoiceSeries`.

### Sequence
A counter inside a Scope. Holds `last_number`. Exactly **one active Sequence per Scope** at any time, enforced by a Postgres partial unique index — never by application code. The counter only ever moves forward: there is no mechanism to reset it, close it, or open a second one, because reusing a Number under the same prefix breaks correlativity. Code name: `InvoiceSequence`.

### Number
The integer identifying an invoice within its Scope. Stored split on the invoice: `series_id` (FK) + `number` (integer). **NULL while the invoice is a Draft.** The display string (`"A-0042"`) is composed at render time from the Scope's prefix and the padded Number — it is never stored.

### Gapless
The numbering invariant: within a Scope, issued Numbers are strictly correlative with no holes (1, 2, 3, …). Required by Spanish invoicing law (RD 1619/2012, Veri*factu). This invariant is why Drafts hold no Number and why reservation happens at issue time inside a single DB transaction.

### Draft
An invoice with status `borrador`. Has **no Number** (`number` IS NULL). Freely editable and freely deletable — carries no fiscal weight. Becomes issued via the explicit Issue transition. Statuses: `borrador` → `pendiente` → `pagada`.

### Issue (verb)
The transition from Draft to issued (`pendiente`). This is the only moment a Number is reserved: lock the Scope's active Sequence row (`SELECT … FOR UPDATE`), increment `last_number`, assign to the invoice, save — all in one transaction. A failed save rolls the counter back; no gap is created. Every invoice is born a Draft, including one created with "save and issue" — that button saves the Draft and then runs this same transition, so an invoice is never persisted as issued-but-unnumbered.

### Issued invoice
An invoice that has left Draft (`pendiente` or `pagada`). Has a Number. **Undeletable and immutable** — fiscal integrity requires that the correlative chain never develops holes and that the content behind a Number never changes. Frozen: Scope, Number, date, client, amounts, and line items. Still mutable: status (`pendiente` → `pagada`), payment terms, and notes. Errors on issued invoices are corrected by rectifying invoices (future feature, conventionally series `"R"`), never by deletion or editing.

## Terms to avoid

- ~~Invoice number as a single string~~ — Number is split storage; the formatted string exists only at render.
- ~~Draft number / provisional number~~ — Drafts have no Number, not even a temporary one.
- ~~Rollover / yearly reset~~ — removed as non-compliant; a Scope's Sequence is continuous for the life of the Scope. Start a new Scope instead.
- ~~Delete invoice~~ — only Drafts can be destroyed; say "delete draft" or "rectify".
- ~~Edit invoice~~ — only Drafts can be edited; say "edit draft" or "rectify".

## Decisions

See `docs/adr/`:

- `0001-invoice-number-sequencing.md` — scoped series, gapless numbering, atomic reservation at issue time, draft lifecycle, migration of legacy numbers.
