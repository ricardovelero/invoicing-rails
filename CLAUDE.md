## Overview

This is a Ruby on Rails app for invoicing.

The application follows standard Rails conventions wherever possible. New features should extend existing patterns instead of introducing new architectural styles.

Primary technologies:

- Ruby on Rails 8.0.5.1
- PostgreSQL
- Hotwire (Turbo + Stimulus)
- Tailwind CSS
- Import Maps
- Minitest
- RSpec
- Capybara

---

# Engineering Principles

Always prefer consistency over cleverness.

When solving a task:

- Make the smallest change that fully solves the problem.
- Extend existing patterns before creating new ones.
- Follow Rails conventions first.
- Avoid introducing unnecessary abstractions.
- Avoid speculative improvements.
- Do not add new gems unless explicitly requested.

The existing architecture should be assumed intentional.

---

# Scope Discipline

Only modify code directly related to the requested task.

Avoid unrelated:

- refactors
- formatting
- renaming
- file moves
- optimizations
- architecture changes

Every changed line should have a reason.

---

# Rails Philosophy

Prefer Rails conventions over custom solutions.

Use:

- Active Record
- Associations
- Scopes
- Validations
- Callbacks only when lifecycle behaviour naturally fits

Prefer:

- RESTful controllers
- Skinny controllers
- Rich domain models

Do not create abstractions simply because code "feels long."

---

# Service Objects

Service Objects are appropriate when they encapsulate a business workflow involving multiple models or external systems.

Do not create services for:

- simple CRUD
- one-line wrappers
- moving model code elsewhere

Always check whether similar services already exist.

---

# Active Record

Prefer:

- scopes
- associations
- eager loading
- query interface

Avoid raw SQL unless there is a measurable reason.

Prefer enforcing integrity in the database whenever possible through:

- foreign keys
- constraints
- indexes

Never modify old migrations.

Create new migrations instead.

---

# Frontend

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

---

# Forms and Icons

The app uses Simple Forms.

---

# Views

Prefer:

- partials
- helpers

Avoid duplicated HTML.

Follow existing Tailwind conventions already present in the project.

---

# Testing

Every bug fix should include a regression test whenever practical.

Prefer:

- model tests for business rules
- request tests for HTTP behaviour
- system tests only for full user flows

Run the smallest appropriate test suite before finishing.

---

# Code Style

- Follow the existing RuboCop configuration.
- Match nearby code.
- Prefer readable code over clever code.
- Write intention-revealing methods.
- Avoid unnecessary comments.

---

# Before Implementing

Before writing code:

1. Understand the existing implementation.
2. Search for similar code.
3. Reuse existing patterns.
4. State assumptions if requirements are ambiguous.

Ask questions only when the ambiguity materially affects the implementation.

---

# Before Finishing

Before considering the task complete:

- run relevant tests
- ensure no unrelated files changed
- verify formatting
- check for regressions
- check that Flowbite components still initialize correctly after Turbo navigation

---

# Useful Commands

## Development

bin/setup

bin/dev

bin/rails console

## Testing

`bin/ci` runs the same checks as the GitHub Actions pull-request workflow:
test database preparation, Zeitwerk, Tailwind CSS compilation, RSpec, Minitest,
and headless Chrome system tests.
It resets the test database and refuses to run with a non-test `RAILS_ENV`.
PostgreSQL and Chrome must be available locally. Use `DATABASE_URL` to override
the test connection when needed; never point it at development or production data.

Individual suites:

- `bundle exec rspec`
- `bin/rails test`
- `bin/rails test:system`

## Quality

`bundle exec rubocop` (there is no `bin/rubocop` wrapper).
Brakeman is not installed in this project; there is no `bin/brakeman` command.

## Database

bin/rails db:migrate

bin/rails db:seed

---

# Documentation

When framework or gem documentation is needed:

- Prefer Context7.
- Follow project conventions over generic examples.
- Documentation should support implementation, not replace established project patterns.

## Agent skills

### Issue tracker

Issues live on GitHub. See `docs/agents/issue-tracker.md`.

### Triage labels

Labels match the canonical five roles. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context. See `docs/agents/domain.md`.
