# ADR 0001: Invoice number sequencing

Status: accepted
Date: 2026-07-21
Amended: 2026-07-23 — removed rollover (non-compliant with Art. 6.1.a RD 1619/2012); numbering is continuous within each series.
Amended: 2026-07-29 — issued invoices are immutable, not merely undeletable (now point 7); reservation is fixed against counter drift and the issued-⇒-numbered invariant is enforced in the database (points 4 and 5).
Amended: 2026-09-06 — dropped the `active` flag on sequences (point 2): with rollover gone it named a state nothing could reach, while leaving the mechanism that reset a series' numbering intact. Issue is atomic on its own rather than by convention (point 4), and an issued invoice must carry its dates, in a chain that cannot travel backwards in time (new point 6, renumbering what follows).

## Context

Invoices were numbered by `Invoice#set_invoice_number` (`Invoice.last.invoice_number.to_i + 1` in a `before_create` callback). This is:

- **Global, not per-user** — one counter shared across all users, so each user's numbers are already gappy.
- **Racy** — two concurrent creates can read the same `last` and assign duplicate numbers.
- **Unscoped** — no concept of series (_serie_), which Spanish invoicing law treats as a first-class concept (rectifying invoices must live in their own series; numbering must be correlative within each series).
- **Deletable history** — issued invoices could be destroyed, punching holes in the correlative chain.

Spanish law (RD 1619/2012; Veri\*factu enforcement from 2026) requires strictly correlative (gapless) numbering within each series.

## Decision

1. **Scope = user-owned series identified by a prefix** (`"A"`, `"R"`). Modeled as `InvoiceSeries` (`user_id`, `prefix`; unique per user).
2. **Sequence = counter inside a scope** (`InvoiceSequence`: `series_id`, `last_number`). Exactly one sequence per scope, for the life of the scope, enforced by a **unique index** on `series_id`, not application code. Numbering is continuous — there is no mechanism to reset or rollover the counter within a series, as reusing numbers under the same prefix violates the correlative requirement. The counter carried an `active` flag until 2026-09-06; rollover was removed in 2026-07-23 but the flag survived it, and with it the reset itself: a deactivated counter was not an error but an invitation, silently replaced by a fresh one at zero, so a series that had reached `A-0102` would issue `A-0001` next. Nothing can now express "this counter is retired", which is the point.
3. **Gapless numbering.** Numbers are strictly correlative within a scope. Consequently:
   - **Drafts hold no number** — new `borrador` status; `number` stays NULL; drafts are freely editable/deletable.
   - **Reservation happens at Issue time**, never at draft creation.
4. **Atomic reservation via row lock.** Issue locks the sequence row (`SELECT … FOR UPDATE`), increments `last_number`, assigns, and saves the invoice in **one transaction**. Rollback on failure restores the counter — no burned numbers. Postgres sequences are rejected (they burn values on rollback); `MAX+1` is rejected (races). The lock must refresh the whole record (`reload(lock: true)`), not just re-read the value: `increment!` derives its delta from the attribute's in-database value, so a stale record advances the counter by more than one and punches the gap this design exists to prevent. `Invoice#issue!` and `#assign_number!` open that transaction themselves, joining the caller's when there is one — the requirement was documented as a contract until 2026-09-06, and a bare call reserved a number it could not roll back.
5. **Split storage.** `invoices` gains `series_id` (FK) + `number` (integer, NULL while draft), unique on `(series_id, number)`. Display strings (`"A-0042"`) are composed at render; nothing formatted is stored. A check constraint enforces that a non-draft row carries both `series_id` and `number`. The converse is deliberately not enforced — Issue writes the Number while the row is still `borrador`, so a numbered draft is valid mid-transaction, and Postgres cannot defer CHECK constraints.
6. **An issued invoice carries its dates, and the chain moves forward in time.** Expedition and due dates are required, enforced in the model and by a check constraint alongside the issued-⇒-numbered one. An invoice cannot take a Number that predates the last invoice issued in its series; the check runs with the sequence row already locked, so concurrent Issues cannot interleave their dates, and it never re-runs on an issued invoice, whose chain is history.
7. **Issued invoices are undeletable and immutable.** `destroy` is blocked for non-draft invoices, and the fields that make up the fiscal document — scope, number, date, client, amounts, and line items — are frozen from the moment the invoice holds a Number in the database. Status, payment terms, and notes stay editable. Rectification via an `"R"` series is a follow-up feature.
8. **Migration preserves legacy numbers.** Each existing user gets default scope `"A"` + one sequence; existing integer `invoice_number` values are copied into `number`; the counter starts at the user's `MAX`. Historical gaps remain as pre-compliance history. Legacy single-string `invoice_number` column is dropped after backfill. New users get their default scope lazily at first Issue.

## Consequences

- The `Invoice.last + 1` callback and its race condition disappear.
- Any code rendering `invoice_number` must go through the composed display method (PDF, views, JSON).
- Deleting an issued invoice now returns an error — a deliberate behavior change.
- Re-rendered PDFs of legacy invoices display `"A-7"` style numbers instead of bare `"7"` — accepted as uniform presentation.
- A future rectification feature adds an `"R"` scope per user and cross-references the rectified invoice; the model already supports it as just another scope.
- If simplified invoices (*facturas simplificadas*) are added, Art. 7.1.a RD 1619/2012 requires them to live in separate series from ordinary invoices within the same calendar year. The model already supports this as just another scope, but the UI and validation must enforce the separation.
