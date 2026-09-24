Enforce client NIF integrity at database level

- Make clients.nif NOT NULL.
- Add a CHECK constraint preventing blank/whitespace-only NIFs.
- Add a unique index on (user_id, nif).
- Clean/verify existing data before adding the constraints.
