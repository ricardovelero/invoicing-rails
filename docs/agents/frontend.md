Hotwire is the default frontend architecture.

The UI is built with Tailwind CSS.

Responsibilities are divided as follows:

- Turbo handles server-rendered navigation and partial page updates.
- Stimulus provides application-specific client-side behaviour.

Prefer:

- Turbo Frames
- Turbo Streams
- Context-preserving modals only for short, interruptible actions: confirmations, quick creation of related records, or inline additions that keep the user in the current workflow. Avoid modal-first CRUD.
- Full create/edit flows should use dedicated pages or Turbo Frames unless staying in context is essential.

Business logic belongs on the server.
