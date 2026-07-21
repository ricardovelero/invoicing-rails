---
kind: business_term
name: Business Glossary
category: business_term
scope:
    - '**'
---

### Factura
- Definition：The core business entity representing an invoice issued by a user to a client; carries status values 'pendiente' (pending) and 'pagada' (paid), line items, and computed totals (subtotal, IVA, IRPF, total).
- Aliases：invoice

### Ítem
- Definition：A reusable product/service template owned by a user that can be attached to invoices as line items; supports soft-delete instead of permanent removal.
- Aliases：item

### Cliente
- Definition：A customer record owned by a user, linked to invoices; also soft-deleted rather than permanently removed.
- Aliases：client

### Línea de factura
- Definition：An individual charge entry on an invoice, referencing an item and carrying quantity, unit price, and computed tax amounts (IVA, IRPF).
- Aliases：line_item

### Perfil de usuario
- Definition：Extended profile data associated with a Devise User (first name, last name, email, locale, freelance flag); stored in a separate table with a circular FK to users.
- Aliases：user_profile

### Pendiente
- Definition：Invoice status meaning 'pending payment'; one of two allowed string values alongside 'pagada'.
- Aliases：pending

### Pagada
- Definition：Invoice status meaning 'paid'; one of two allowed string values alongside 'pendiente'.
- Aliases：paid

### IVA
- Definition：Value-added tax amount computed per line item and summed into the invoice total; stored as a decimal column on both line items and invoices.
- Aliases：VAT

### IRPF
- Definition：Spanish income-tax withholding amount applied to line items and included in invoice totals; persisted as a dedicated column.
- Aliases：withholding tax

### Soft delete
- Definition：Deletion strategy used for items, clients, and invoices where records are marked inactive rather than physically removed, with a dedicated archive section to manage them.
- Aliases：archived records

### Onboarding
- Definition：Multi-step registration flow for new subscribers, implemented via the Wicked gem wizard controllers under the `after_register` namespace.
- Aliases：subscriber onboarding
