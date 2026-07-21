# ADR 0001: Invoice number sequencing

Status: accepted
Date: 2026-07-21

## Context

Invoices were numbered by `Invoice#set_invoice_number` (`Invoice.last.invoice_number.to_i + 1` in a `before_create` callback). This is:

- **Global, not per-user** — one counter shared across all users, so each user's numbers are already gappy.
- **Racy** — two concurrent creates can read the same `last` and assign duplicate numbers.
- **Unscoped** — no concept of series (*serie*), which Spanish invoicing law treats as a first-class concept (rectifying invoices must live in their own series; numbering must be correlative within each series).
- **Deletable history** — issued invoices could be destroyed, punching holes in the correlative chain.

Spanish law (RD 1619/2012; Veri*factu enforcement from 2026) requires strictly correlative (gapless) numbering within each series.

## Decision

1. **Scope = user-owned series identified by a prefix** (`"A"`, `"R"`). Modeled as `InvoiceSeries` (`user_id`, `prefix`; unique per user).
2. **Sequence = counter inside a scope** (`InvoiceSequence`: `series_id`, `last_number`, `active`, optional year label). Exactly one active sequence per scope, enforced by a **partial unique index** (`WHERE active`), not application code.
3. **Gapless numbering.** Numbers are strictly correlative within a scope. Consequently:
   - **Drafts hold no number** — new `borrador` status; `number` stays NULL; drafts are freely editable/deletable.
   - **Reservation happens at Issue time**, never at draft creation.
4. **Atomic reservation via row lock.** Issue locks the active sequence row (`SELECT … FOR UPDATE`), increments `last_number`, assigns, and saves the invoice in **one transaction**. Rollback on failure restores the counter — no burned numbers. Postgres sequences are rejected (they burn values on rollback); `MAX+1` is rejected (races).
5. **Split storage.** `invoices` gains `series_id` (FK) + `number` (integer, NULL while draft), unique on `(series_id, number)`. Display strings (`"A-0042"`) are composed at render; nothing formatted is stored.
6. **Manual rollover only.** Issue always draws from the scope's active sequence regardless of invoice date. Yearly reset is not automatic; users close and open sequences explicitly. (One continuous series is legal; correlative is the requirement.)
7. **Issued invoices are undeletable.** `destroy` is blocked for non-draft invoices. Rectification via an `"R"` series is a follow-up feature.
8. **Migration preserves legacy numbers.** Each existing user gets default scope `"A"` + one active sequence; existing integer `invoice_number` values are copied into `number`; the counter starts at the user's `MAX`. Historical gaps remain as pre-compliance history. Legacy single-string `invoice_number` column is dropped after backfill. New users get their default scope lazily at first Issue.

## Consequences

- The `Invoice.last + 1` callback and its race condition disappear.
- Any code rendering `invoice_number` must go through the composed display method (PDF, views, JSON).
- Deleting an issued invoice now returns an error — a deliberate behavior change.
- Re-rendered PDFs of legacy invoices display `"A-7"` style numbers instead of bare `"7"` — accepted as uniform presentation.
- A future rectification feature adds an `"R"` scope per user and cross-references the rectified invoice; the model already supports it as just another scope.
- Year-labeled sequences (`"A-2026-…"`) remain possible as cosmetic labels without any date-driven logic.
