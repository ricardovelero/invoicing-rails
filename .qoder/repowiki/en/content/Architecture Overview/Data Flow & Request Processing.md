# Data Flow & Request Processing

<cite>
**Referenced Files in This Document**
- [routes.rb](file://config/routes.rb)
- [application_controller.rb](file://app/controllers/application_controller.rb)
- [invoices_controller.rb](file://app/controllers/invoices_controller.rb)
- [clients_controller.rb](file://app/controllers/clients_controller.rb)
- [dashboard_controller.rb](file://app/controllers/dashboard_controller.rb)
- [line_items_controller.rb](file://app/controllers/line_items_controller.rb)
- [items_controller.rb](file://app/controllers/items_controller.rb)
- [invoice.rb](file://app/models/invoice.rb)
- [client.rb](file://app/models/client.rb)
- [item.rb](file://app/models/item.rb)
- [line_item.rb](file://app/models/line_item.rb)
- [current_invoice.rb](file://app/controllers/concerns/current_invoice.rb)
- [form_validation_controller.js](file://app/javascript/controllers/form_validation_controller.js)
- [recalculate_controller.js](file://app/javascript/controllers/recalculate_controller.js)
- [removeitem_controller.js](file://app/javascript/controllers/removeitem_controller.js)
- [modal_controller.js](file://app/javascript/controllers/modal_controller.js)
- [index.js](file://app/javascript/controllers/index.js)
- [application.js](file://app/javascript/application.js)
- [create.turbo_stream.erb](file://app/views/clients/create.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/clients/update.turbo_stream.erb)
- [show.turbo_stream.erb](file://app/views/clients/show.turbo_stream.erb)
- [create.turbo_stream.erb](file://app/views/items/create.turbo_stream.erb)
- [show.turbo_stream.erb](file://app/views/items/show.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/invoices/update.turbo_stream.erb)
- [regions.turbo_stream.erb](file://app/views/countries/regions.turbo_stream.erb)
- [_form.html.erb](file://app/views/invoices/_form.html.erb)
- [_total.html.erb](file://app/views/invoices/_total.html.erb)
- [_client.html.erb](file://app/views/clients/_client.html.erb)
- [_item.html.erb](file://app/views/items/_item.html.erb)
- [schema.rb](file://db/schema.rb)
</cite>

## Table of Contents
1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Core Components](#core-components)
4. [Architecture Overview](#architecture-overview)
5. [Detailed Component Analysis](#detailed-component-analysis)
6. [Dependency Analysis](#dependency-analysis)
7. [Performance Considerations](#performance-considerations)
8. [Troubleshooting Guide](#troubleshooting-guide)
9. [Conclusion](#conclusion)

## Introduction
This document explains the end-to-end data flow and request processing architecture of the Invoicing Rails application. It covers the full HTTP lifecycle from route dispatch through controller actions, model validations, database operations, and view rendering. It also documents Turbo Streams for real-time partial updates and Stimulus.js controllers that enhance client-side interactions. Typical user workflows such as invoice creation, client management, and dashboard updates are illustrated with sequence diagrams. Error handling, validation flows, and asynchronous patterns are addressed to help developers understand both server-side and client-side behavior.

## Project Structure
The application follows a conventional Rails layout:
- Controllers under app/controllers handle HTTP requests and coordinate business logic.
- Models under app/models encapsulate domain entities and validations.
- Views under app/views render HTML or Turbo Stream fragments.
- JavaScript controllers under app/javascript/controllers implement client-side behaviors using Stimulus.js.
- Routes under config/routes.rb define URL mappings to controller actions.
- Database schema is defined in db/schema.rb.

```mermaid
graph TB
Client["Browser<br/>Turbo + Stimulus"] --> Router["Rails Router<br/>config/routes.rb"]
Router --> ApplicationController["ApplicationController<br/>filters & helpers"]
ApplicationController --> InvoicesCtrl["InvoicesController"]
ApplicationController --> ClientsCtrl["ClientsController"]
ApplicationController --> DashboardCtrl["DashboardController"]
InvoicesCtrl --> InvoiceModel["Invoice Model"]
InvoicesCtrl --> LineItemModel["LineItem Model"]
ClientsCtrl --> ClientModel["Client Model"]
DashboardCtrl --> ChartsModels["Charts Models"]
InvoicesCtrl --> ViewForm["_form.html.erb"]
InvoicesCtrl --> ViewTotal["_total.html.erb"]
ClientsCtrl --> ViewClient["_client.html.erb"]
InvoicesCtrl --> TurboUpdate["update.turbo_stream.erb"]
ClientsCtrl --> TurboCreate["create.turbo_stream.erb"]
ClientsCtrl --> TurboShow["show.turbo_stream.erb"]
ClientsCtrl --> TurboUpdateC["update.turbo_stream.erb"]
ItemsCtrl --> TurboItemsCreate["items/create.turbo_stream.erb"]
ItemsCtrl --> TurboItemsShow["items/show.turbo_stream.erb"]
CountriesCtrl --> RegionsStream["countries/regions.turbo_stream.erb"]
Stimulus["Stimulus Controllers<br/>form_validation, recalculate, removeitem, modal"] --> Client
```

**Diagram sources**
- [routes.rb](file://config/routes.rb)
- [application_controller.rb](file://app/controllers/application_controller.rb)
- [invoices_controller.rb](file://app/controllers/invoices_controller.rb)
- [clients_controller.rb](file://app/controllers/clients_controller.rb)
- [dashboard_controller.rb](file://app/controllers/dashboard_controller.rb)
- [invoice.rb](file://app/models/invoice.rb)
- [client.rb](file://app/models/client.rb)
- [line_item.rb](file://app/models/line_item.rb)
- [items_controller.rb](file://app/controllers/items_controller.rb)
- [create.turbo_stream.erb](file://app/views/clients/create.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/clients/update.turbo_stream.erb)
- [show.turbo_stream.erb](file://app/views/clients/show.turbo_stream.erb)
- [create.turbo_stream.erb](file://app/views/items/create.turbo_stream.erb)
- [show.turbo_stream.erb](file://app/views/items/show.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/invoices/update.turbo_stream.erb)
- [regions.turbo_stream.erb](file://app/views/countries/regions.turbo_stream.erb)
- [_form.html.erb](file://app/views/invoices/_form.html.erb)
- [_total.html.erb](file://app/views/invoices/_total.html.erb)
- [_client.html.erb](file://app/views/clients/_client.html.erb)
- [form_validation_controller.js](file://app/javascript/controllers/form_validation_controller.js)
- [recalculate_controller.js](file://app/javascript/controllers/recalculate_controller.js)
- [removeitem_controller.js](file://app/javascript/controllers/removeitem_controller.js)
- [modal_controller.js](file://app/javascript/controllers/modal_controller.js)

**Section sources**
- [routes.rb](file://config/routes.rb)
- [application_controller.rb](file://app/controllers/application_controller.rb)
- [invoices_controller.rb](file://app/controllers/invoices_controller.rb)
- [clients_controller.rb](file://app/controllers/clients_controller.rb)
- [dashboard_controller.rb](file://app/controllers/dashboard_controller.rb)
- [invoice.rb](file://app/models/invoice.rb)
- [client.rb](file://app/models/client.rb)
- [line_item.rb](file://app/models/line_item.rb)
- [items_controller.rb](file://app/controllers/items_controller.rb)
- [create.turbo_stream.erb](file://app/views/clients/create.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/clients/update.turbo_stream.erb)
- [show.turbo_stream.erb](file://app/views/clients/show.turbo_stream.erb)
- [create.turbo_stream.erb](file://app/views/items/create.turbo_stream.erb)
- [show.turbo_stream.erb](file://app/views/items/show.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/invoices/update.turbo_stream.erb)
- [regions.turbo_stream.erb](file://app/views/countries/regions.turbo_stream.erb)
- [_form.html.erb](file://app/views/invoices/_form.html.erb)
- [_total.html.erb](file://app/views/invoices/_total.html.erb)
- [_client.html.erb](file://app/views/clients/_client.html.erb)
- [form_validation_controller.js](file://app/javascript/controllers/form_validation_controller.js)
- [recalculate_controller.js](file://app/javascript/controllers/recalculate_controller.js)
- [removeitem_controller.js](file://app/javascript/controllers/removeitem_controller.js)
- [modal_controller.js](file://app/javascript/controllers/modal_controller.js)

## Core Components
- Routing layer maps URLs to controller actions and supports Turbo Stream responses.
- Application controller provides shared filters and helper methods used by feature controllers.
- Feature controllers (invoices, clients, items, line items, dashboard) orchestrate request handling, model interactions, and view/Turbo Stream rendering.
- Models enforce domain rules via validations and associations.
- Views include standard ERB templates and Turbo Stream templates for partial updates.
- Stimulus controllers manage client-side form validation, dynamic recalculation, item removal, and modals.

Key responsibilities:
- InvoicesController: create, update, show; uses Turbo Stream for live totals and partial updates.
- ClientsController: index, new, create, edit, update, show; integrates Turbo Streams for instant feedback.
- ItemsController: CRUD with Turbo Stream responses for seamless UX.
- LineItemsController: manages invoice line items and participates in total calculations.
- DashboardController: renders charts and aggregates data.

**Section sources**
- [invoices_controller.rb](file://app/controllers/invoices_controller.rb)
- [clients_controller.rb](file://app/controllers/clients_controller.rb)
- [items_controller.rb](file://app/controllers/items_controller.rb)
- [line_items_controller.rb](file://app/controllers/line_items_controller.rb)
- [dashboard_controller.rb](file://app/controllers/dashboard_controller.rb)
- [invoice.rb](file://app/models/invoice.rb)
- [client.rb](file://app/models/client.rb)
- [item.rb](file://app/models/item.rb)
- [line_item.rb](file://app/models/line_item.rb)
- [form_validation_controller.js](file://app/javascript/controllers/form_validation_controller.js)
- [recalculate_controller.js](file://app/javascript/controllers/recalculate_controller.js)
- [removeitem_controller.js](file://app/javascript/controllers/removeitem_controller.js)
- [modal_controller.js](file://app/javascript/controllers/modal_controller.js)

## Architecture Overview
The application leverages Rails MVC plus Turbo and Stimulus for a modern, interactive experience:
- Requests enter via routes and are dispatched to controllers.
- Controllers validate inputs, persist data, and respond with either HTML or Turbo Stream fragments.
- Models encapsulate validations and relationships.
- Views render UI; Turbo replaces targeted DOM nodes without full page reloads.
- Stimulus controllers enhance forms, perform client-side recalculations, and manage modals.

```mermaid
sequenceDiagram
participant U as "User"
participant B as "Browser<br/>Turbo + Stimulus"
participant R as "Router"
participant C as "Controller"
participant M as "Model"
participant V as "View / Turbo Stream"
U->>B : Interact (submit form, click link)
B->>R : HTTP request (GET/POST/PATCH)
R->>C : Dispatch action
C->>M : Validate & persist
M-->>C : Result (success/failure)
alt Success
C->>V : Render HTML or Turbo Stream
V-->>B : Partial update (replace/append)
B->>B : Stimulus handles events
else Failure
C->>V : Render errors (HTML or Turbo Stream)
V-->>B : Show inline errors
end
```

**Diagram sources**
- [routes.rb](file://config/routes.rb)
- [application_controller.rb](file://app/controllers/application_controller.rb)
- [invoices_controller.rb](file://app/controllers/invoices_controller.rb)
- [clients_controller.rb](file://app/controllers/clients_controller.rb)
- [items_controller.rb](file://app/controllers/items_controller.rb)
- [invoice.rb](file://app/models/invoice.rb)
- [client.rb](file://app/models/client.rb)
- [item.rb](file://app/models/item.rb)
- [create.turbo_stream.erb](file://app/views/clients/create.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/clients/update.turbo_stream.erb)
- [show.turbo_stream.erb](file://app/views/clients/show.turbo_stream.erb)
- [create.turbo_stream.erb](file://app/views/items/create.turbo_stream.erb)
- [show.turbo_stream.erb](file://app/views/items/show.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/invoices/update.turbo_stream.erb)

## Detailed Component Analysis

### Invoice Creation Workflow
This workflow demonstrates how a user creates an invoice, including client selection, line item addition, and total calculation. Turbo Streams provide immediate feedback on updates.

```mermaid
sequenceDiagram
participant U as "User"
participant B as "Browser<br/>Turbo + Stimulus"
participant R as "Router"
participant IC as "InvoicesController"
participant IM as "Invoice Model"
participant LM as "LineItem Model"
participant CM as "Client Model"
participant V as "Views / Turbo Streams"
U->>B : Open new invoice form
B->>R : GET /invoices/new
R->>IC : new
IC->>CM : list clients
IC->>V : render _form.html.erb
V-->>B : Form with client select and line items
U->>B : Submit invoice
B->>R : POST /invoices
R->>IC : create
IC->>IM : build + save
alt Valid
IC->>LM : create associated line items
LM-->>IC : persisted
IC->>V : render update.turbo_stream.erb
V-->>B : Replace totals and confirmations
else Invalid
IC->>V : re-render form with errors
V-->>B : Show validation messages
end
```

**Diagram sources**
- [routes.rb](file://config/routes.rb)
- [invoices_controller.rb](file://app/controllers/invoices_controller.rb)
- [invoice.rb](file://app/models/invoice.rb)
- [line_item.rb](file://app/models/line_item.rb)
- [client.rb](file://app/models/client.rb)
- [_form.html.erb](file://app/views/invoices/_form.html.erb)
- [_total.html.erb](file://app/views/invoices/_total.html.erb)
- [update.turbo_stream.erb](file://app/views/invoices/update.turbo_stream.erb)

**Section sources**
- [invoices_controller.rb](file://app/controllers/invoices_controller.rb)
- [invoice.rb](file://app/models/invoice.rb)
- [line_item.rb](file://app/models/line_item.rb)
- [client.rb](file://app/models/client.rb)
- [_form.html.erb](file://app/views/invoices/_form.html.erb)
- [_total.html.erb](file://app/views/invoices/_total.html.erb)
- [update.turbo_stream.erb](file://app/views/invoices/update.turbo_stream.erb)

### Client Management Workflow
This workflow covers creating and updating clients with Turbo Streams for instant UI updates.

```mermaid
sequenceDiagram
participant U as "User"
participant B as "Browser<br/>Turbo + Stimulus"
participant R as "Router"
participant CC as "ClientsController"
participant CM as "Client Model"
participant V as "Views / Turbo Streams"
U->>B : Click "New Client"
B->>R : GET /clients/new
R->>CC : new
CC->>V : render new.html.erb
V-->>B : Form
U->>B : Submit client form
B->>R : POST /clients
R->>CC : create
CC->>CM : save
alt Valid
CC->>V : render create.turbo_stream.erb
V-->>B : Append client row/list item
else Invalid
CC->>V : re-render form with errors
V-->>B : Show inline errors
end
U->>B : Edit client
B->>R : PATCH /clients/ : id
R->>CC : update
CC->>CM : update
alt Valid
CC->>V : render update.turbo_stream.erb
V-->>B : Update client details
else Invalid
CC->>V : re-render form with errors
V-->>B : Show inline errors
end
```

**Diagram sources**
- [routes.rb](file://config/routes.rb)
- [clients_controller.rb](file://app/controllers/clients_controller.rb)
- [client.rb](file://app/models/client.rb)
- [create.turbo_stream.erb](file://app/views/clients/create.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/clients/update.turbo_stream.erb)
- [show.turbo_stream.erb](file://app/views/clients/show.turbo_stream.erb)

**Section sources**
- [clients_controller.rb](file://app/controllers/clients_controller.rb)
- [client.rb](file://app/models/client.rb)
- [create.turbo_stream.erb](file://app/views/clients/create.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/clients/update.turbo_stream.erb)
- [show.turbo_stream.erb](file://app/views/clients/show.turbo_stream.erb)

### Dashboard Updates
The dashboard controller renders aggregated data and charts. Turbo can be used to refresh chart sections without reloading the entire page.

```mermaid
sequenceDiagram
participant U as "User"
participant B as "Browser"
participant R as "Router"
participant DC as "DashboardController"
participant CM as "Charts Models"
participant V as "Dashboard View"
U->>B : Visit dashboard
B->>R : GET /dashboard
R->>DC : index
DC->>CM : query aggregates
CM-->>DC : chart data
DC->>V : render index.html.erb
V-->>B : Charts and summary cards
```

**Diagram sources**
- [routes.rb](file://config/routes.rb)
- [dashboard_controller.rb](file://app/controllers/dashboard_controller.rb)

**Section sources**
- [dashboard_controller.rb](file://app/controllers/dashboard_controller.rb)

### Turbo Streams Integration
Turbo Streams enable real-time partial updates by sending stream actions that replace or append DOM elements. The application uses Turbo Stream templates for key features:
- Clients: create, update, show streams.
- Items: create and show streams.
- Invoices: update stream for totals and status.
- Countries: regions stream for dependent selects.

```mermaid
flowchart TD
Start(["Request Received"]) --> Action{"Action Type"}
Action --> |Create| CreateStream["Render create.turbo_stream.erb"]
Action --> |Update| UpdateStream["Render update.turbo_stream.erb"]
Action --> |Show| ShowStream["Render show.turbo_stream.erb"]
CreateStream --> Replace["Replace or append target node"]
UpdateStream --> Replace
ShowStream --> Replace
Replace --> End(["UI Updated"])
```

**Diagram sources**
- [create.turbo_stream.erb](file://app/views/clients/create.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/clients/update.turbo_stream.erb)
- [show.turbo_stream.erb](file://app/views/clients/show.turbo_stream.erb)
- [create.turbo_stream.erb](file://app/views/items/create.turbo_stream.erb)
- [show.turbo_stream.erb](file://app/views/items/show.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/invoices/update.turbo_stream.erb)
- [regions.turbo_stream.erb](file://app/views/countries/regions.turbo_stream.erb)

**Section sources**
- [create.turbo_stream.erb](file://app/views/clients/create.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/clients/update.turbo_stream.erb)
- [show.turbo_stream.erb](file://app/views/clients/show.turbo_stream.erb)
- [create.turbo_stream.erb](file://app/views/items/create.turbo_stream.erb)
- [show.turbo_stream.erb](file://app/views/items/show.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/invoices/update.turbo_stream.erb)
- [regions.turbo_stream.erb](file://app/views/countries/regions.turbo_stream.erb)

### Stimulus.js Controller Interactions
Stimulus controllers enhance interactivity:
- form_validation_controller.js: performs client-side validation and shows inline errors.
- recalculate_controller.js: recalculates totals when quantities or prices change.
- removeitem_controller.js: removes line items dynamically.
- modal_controller.js: toggles modal visibility.
- index.js and application.js: bootstraps Stimulus and registers controllers.

```mermaid
sequenceDiagram
participant U as "User"
participant B as "Browser"
participant S as "Stimulus Controller"
participant F as "Form Element"
participant T as "Target Node"
U->>F : Input changes
F->>S : Event dispatch (input/change)
S->>S : Validate fields / compute values
S->>T : Update DOM (errors/totals)
U->>F : Submit form
F->>S : Confirm validity
S-->>U : Proceed or prevent submission
```

**Diagram sources**
- [form_validation_controller.js](file://app/javascript/controllers/form_validation_controller.js)
- [recalculate_controller.js](file://app/javascript/controllers/recalculate_controller.js)
- [removeitem_controller.js](file://app/javascript/controllers/removeitem_controller.js)
- [modal_controller.js](file://app/javascript/controllers/modal_controller.js)
- [index.js](file://app/javascript/controllers/index.js)
- [application.js](file://app/javascript/application.js)

**Section sources**
- [form_validation_controller.js](file://app/javascript/controllers/form_validation_controller.js)
- [recalculate_controller.js](file://app/javascript/controllers/recalculate_controller.js)
- [removeitem_controller.js](file://app/javascript/controllers/removeitem_controller.js)
- [modal_controller.js](file://app/javascript/controllers/modal_controller.js)
- [index.js](file://app/javascript/controllers/index.js)
- [application.js](file://app/javascript/application.js)

### Validation and Error Handling
Validation occurs at multiple layers:
- Client-side: Stimulus controllers check required fields and formats before submission.
- Server-side: Models enforce presence, uniqueness, numericality, and custom rules.
- Controller actions respond with Turbo Stream or HTML containing error messages.

```mermaid
flowchart TD
Entry(["Submit Request"]) --> ClientValidate["Stimulus Validation"]
ClientValidate --> Valid{"Valid?"}
Valid --> |No| ShowErrors["Display inline errors"]
Valid --> |Yes| ServerSave["Controller persists via Model"]
ServerSave --> ServerValid{"Model valid?"}
ServerValid --> |No| RenderErrors["Render form/errors (HTML or Turbo)"]
ServerValid --> |Yes| Success["Render success (HTML or Turbo)"]
ShowErrors --> Exit(["End"])
RenderErrors --> Exit
Success --> Exit
```

**Diagram sources**
- [form_validation_controller.js](file://app/javascript/controllers/form_validation_controller.js)
- [invoice.rb](file://app/models/invoice.rb)
- [client.rb](file://app/models/client.rb)
- [item.rb](file://app/models/item.rb)
- [line_item.rb](file://app/models/line_item.rb)
- [update.turbo_stream.erb](file://app/views/invoices/update.turbo_stream.erb)
- [create.turbo_stream.erb](file://app/views/clients/create.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/clients/update.turbo_stream.erb)

**Section sources**
- [form_validation_controller.js](file://app/javascript/controllers/form_validation_controller.js)
- [invoice.rb](file://app/models/invoice.rb)
- [client.rb](file://app/models/client.rb)
- [item.rb](file://app/models/item.rb)
- [line_item.rb](file://app/models/line_item.rb)
- [update.turbo_stream.erb](file://app/views/invoices/update.turbo_stream.erb)
- [create.turbo_stream.erb](file://app/views/clients/create.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/clients/update.turbo_stream.erb)

### Asynchronous Operations
Asynchronous updates are primarily handled via Turbo Streams:
- Turbo frames and streams allow partial updates without full page reloads.
- Stimulus controllers trigger local updates (e.g., recalculations) while background server operations complete.
- For long-running tasks, consider Active Job integration (not shown here), which would complement Turbo Streams for progress updates.

[No sources needed since this section provides general guidance]

## Dependency Analysis
The following diagram highlights core dependencies between controllers, models, views, and Turbo Stream templates.

```mermaid
graph LR
Routes["Routes"] --> InvoicesCtrl["InvoicesController"]
Routes --> ClientsCtrl["ClientsController"]
Routes --> ItemsCtrl["ItemsController"]
Routes --> DashboardCtrl["DashboardController"]
InvoicesCtrl --> InvoiceModel["Invoice"]
InvoicesCtrl --> LineItemModel["LineItem"]
InvoicesCtrl --> ClientModel["Client"]
InvoicesCtrl --> InvoiceForm["_form.html.erb"]
InvoicesCtrl --> InvoiceTotal["_total.html.erb"]
InvoicesCtrl --> InvoiceUpdateStream["update.turbo_stream.erb"]
ClientsCtrl --> ClientModel
ClientsCtrl --> ClientPartial["_client.html.erb"]
ClientsCtrl --> ClientCreateStream["create.turbo_stream.erb"]
ClientsCtrl --> ClientUpdateStream["update.turbo_stream.erb"]
ClientsCtrl --> ClientShowStream["show.turbo_stream.erb"]
ItemsCtrl --> ItemModel["Item"]
ItemsCtrl --> ItemPartial["_item.html.erb"]
ItemsCtrl --> ItemCreateStream["items/create.turbo_stream.erb"]
ItemsCtrl --> ItemShowStream["items/show.turbo_stream.erb"]
DashboardCtrl --> ChartsModels["Charts Models"]
```

**Diagram sources**
- [routes.rb](file://config/routes.rb)
- [invoices_controller.rb](file://app/controllers/invoices_controller.rb)
- [clients_controller.rb](file://app/controllers/clients_controller.rb)
- [items_controller.rb](file://app/controllers/items_controller.rb)
- [dashboard_controller.rb](file://app/controllers/dashboard_controller.rb)
- [invoice.rb](file://app/models/invoice.rb)
- [client.rb](file://app/models/client.rb)
- [item.rb](file://app/models/item.rb)
- [line_item.rb](file://app/models/line_item.rb)
- [_form.html.erb](file://app/views/invoices/_form.html.erb)
- [_total.html.erb](file://app/views/invoices/_total.html.erb)
- [_client.html.erb](file://app/views/clients/_client.html.erb)
- [_item.html.erb](file://app/views/items/_item.html.erb)
- [create.turbo_stream.erb](file://app/views/clients/create.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/clients/update.turbo_stream.erb)
- [show.turbo_stream.erb](file://app/views/clients/show.turbo_stream.erb)
- [create.turbo_stream.erb](file://app/views/items/create.turbo_stream.erb)
- [show.turbo_stream.erb](file://app/views/items/show.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/invoices/update.turbo_stream.erb)

**Section sources**
- [routes.rb](file://config/routes.rb)
- [invoices_controller.rb](file://app/controllers/invoices_controller.rb)
- [clients_controller.rb](file://app/controllers/clients_controller.rb)
- [items_controller.rb](file://app/controllers/items_controller.rb)
- [dashboard_controller.rb](file://app/controllers/dashboard_controller.rb)
- [invoice.rb](file://app/models/invoice.rb)
- [client.rb](file://app/models/client.rb)
- [item.rb](file://app/models/item.rb)
- [line_item.rb](file://app/models/line_item.rb)
- [_form.html.erb](file://app/views/invoices/_form.html.erb)
- [_total.html.erb](file://app/views/invoices/_total.html.erb)
- [_client.html.erb](file://app/views/clients/_client.html.erb)
- [_item.html.erb](file://app/views/items/_item.html.erb)
- [create.turbo_stream.erb](file://app/views/clients/create.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/clients/update.turbo_stream.erb)
- [show.turbo_stream.erb](file://app/views/clients/show.turbo_stream.erb)
- [create.turbo_stream.erb](file://app/views/items/create.turbo_stream.erb)
- [show.turbo_stream.erb](file://app/views/items/show.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/invoices/update.turbo_stream.erb)

## Performance Considerations
- Prefer Turbo Streams for frequent small updates to avoid full page reloads.
- Keep model validations minimal and focused to reduce server overhead.
- Use efficient queries in dashboard charts; consider caching frequently accessed aggregates.
- Debounce client-side recalculations to minimize unnecessary DOM updates.
- Ensure Turbo targets are specific to reduce reflows and repaints.

[No sources needed since this section provides general guidance]

## Troubleshooting Guide
Common issues and resolutions:
- Turbo Stream not applied: verify the response content type is text/vnd.turbo-stream.html and that the target element exists in the DOM.
- Inline errors not showing: ensure Stimulus validation triggers on input/change and that error containers match expected selectors.
- Totals not updating: confirm recalculate controller listens to relevant events and that Turbo streams replace the correct totals container.
- Modal not closing: check modal controller event bindings and ensure data attributes are correctly set.

**Section sources**
- [form_validation_controller.js](file://app/javascript/controllers/form_validation_controller.js)
- [recalculate_controller.js](file://app/javascript/controllers/recalculate_controller.js)
- [removeitem_controller.js](file://app/javascript/controllers/removeitem_controller.js)
- [modal_controller.js](file://app/javascript/controllers/modal_controller.js)
- [update.turbo_stream.erb](file://app/views/invoices/update.turbo_stream.erb)
- [create.turbo_stream.erb](file://app/views/clients/create.turbo_stream.erb)
- [update.turbo_stream.erb](file://app/views/clients/update.turbo_stream.erb)
- [show.turbo_stream.erb](file://app/views/clients/show.turbo_stream.erb)

## Conclusion
The Invoicing Rails application combines Rails MVC with Turbo Streams and Stimulus.js to deliver a responsive, real-time user experience. Requests flow through routing to controllers, which coordinate model validations and persistence, then render either HTML or Turbo Stream fragments. Client-side Stimulus controllers enhance forms, perform recalculations, and manage modals. By leveraging Turbo Streams for partial updates and maintaining clear separation of concerns, the system achieves both performance and maintainability.