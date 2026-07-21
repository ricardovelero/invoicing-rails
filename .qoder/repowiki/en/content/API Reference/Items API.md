# Items API

<cite>
**Referenced Files in This Document**
- [items_controller.rb](file://app/controllers/items_controller.rb)
- [item.rb](file://app/models/item.rb)
- [routes.rb](file://config/routes.rb)
- [_item.json.jbuilder](file://app/views/items/_item.json.jbuilder)
- [index.json.jbuilder](file://app/views/items/index.json.jbuilder)
- [show.json.jbuilder](file://app/views/items/show.json.jbuilder)
- [line_item.rb](file://app/models/line_item.rb)
- [invoice.rb](file://app/models/invoice.rb)
</cite>

## Table of Contents
1. [Introduction](#introduction)
2. [Authentication](#authentication)
3. [Base URL](#base-url)
4. [Items Collection Endpoints](#items-collection-endpoints)
5. [Individual Item Endpoints](#individual-item-endpoints)
6. [Request Parameters](#request-parameters)
7. [Response Schemas](#response-schemas)
8. [Error Handling](#error-handling)
9. [Integration with Line Items](#integration-with-line-items)
10. [Examples](#examples)
11. [Best Practices](#best-practices)

## Introduction

The Items API provides RESTful endpoints for managing item catalogs in the invoicing system. Items represent products or services that can be added to invoices with associated pricing, tax configurations, and categorization. This API supports full CRUD operations along with advanced filtering, search, and pagination capabilities.

## Authentication

All Items API endpoints require authentication using Devise token-based authentication. Include the following headers in your requests:

```
Authorization: Bearer YOUR_API_TOKEN
Content-Type: application/json
Accept: application/json
```

API tokens can be obtained through the user registration and login endpoints.

## Base URL

All Items API endpoints are relative to:
```
/api/items
```

## Items Collection Endpoints

### GET /api/items

Retrieve a paginated list of items with optional filtering and search capabilities.

#### Query Parameters

| Parameter | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `page` | integer | No | Page number for pagination (default: 1) | `?page=2` |
| `per_page` | integer | No | Number of items per page (default: 25, max: 100) | `?per_page=50` |
| `search` | string | No | Search query for item name and description | `?search=laptop` |
| `category` | string | No | Filter by category | `?category=electronics` |
| `min_price` | decimal | No | Minimum price filter | `?min_price=10.00` |
| `max_price` | decimal | No | Maximum price filter | `?max_price=1000.00` |
| `available` | boolean | No | Filter by availability status | `?available=true` |
| `sort` | string | No | Sort field (name, price, created_at) | `?sort=price` |
| `order` | string | No | Sort order (asc, desc) | `?order=desc` |

#### Response Format

Returns a JSON object containing:
- `data`: Array of item objects
- `meta`: Pagination metadata
- `links`: Pagination links

#### Status Codes
- `200 OK`: Successful retrieval
- `401 Unauthorized`: Missing or invalid authentication
- `403 Forbidden`: Insufficient permissions

### POST /api/items

Create a new item with pricing and tax configuration.

#### Request Body

```json
{
  "item": {
    "name": "Professional Services",
    "description": "Consulting and development services",
    "category": "services",
    "unit_price": 150.00,
    "currency": "USD",
    "tax_rate": 21.0,
    "tax_included": false,
    "sku": "SRV-001",
    "is_available": true,
    "tags": ["consulting", "development"]
  }
}
```

#### Validation Rules

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| `name` | string | Yes | Max 255 characters, unique per user |
| `description` | string | No | Max 1000 characters |
| `category` | string | No | Max 100 characters |
| `unit_price` | decimal | Yes | Must be positive, max 999999999.99 |
| `currency` | string | No | ISO 4217 currency code (default: USD) |
| `tax_rate` | decimal | No | 0-100 percentage (default: 0) |
| `tax_included` | boolean | No | Whether tax is included in unit price |
| `sku` | string | No | Unique SKU identifier |
| `is_available` | boolean | No | Availability status (default: true) |
| `tags` | array | No | Array of tag strings |

#### Response Format

Returns the created item object with status `201 Created`.

#### Status Codes
- `201 Created`: Item successfully created
- `400 Bad Request`: Validation errors
- `401 Unauthorized`: Missing or invalid authentication
- `409 Conflict`: Duplicate SKU or name

## Individual Item Endpoints

### GET /api/items/:id

Retrieve details for a specific item.

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | integer | Yes | Item ID |

#### Response Format

Returns a single item object with complete details including usage statistics.

#### Status Codes
- `200 OK`: Item found
- `401 Unauthorized`: Missing or invalid authentication
- `404 Not Found`: Item not found

### PUT /api/items/:id

Update an existing item's properties.

#### Request Body

Same structure as POST request, but only include fields to update.

#### Status Codes
- `200 OK`: Item successfully updated
- `400 Bad Request`: Validation errors
- `401 Unauthorized`: Missing or invalid authentication
- `404 Not Found`: Item not found
- `409 Conflict`: Duplicate SKU or name

### DELETE /api/items/:id

Delete an item from the catalog.

#### Status Codes
- `204 No Content`: Item successfully deleted
- `401 Unauthorized`: Missing or invalid authentication
- `404 Not Found`: Item not found
- `422 Unprocessable Entity`: Item is referenced by line items

## Request Parameters

### Advanced Filtering

The API supports complex filtering combinations:

```
GET /api/items?category=electronics&min_price=100&max_price=500&available=true&search=gaming
```

### Search Functionality

Search queries support:
- Partial matching in item names
- Description text searching
- Tag-based filtering
- Category-specific searches

### Sorting Options

Available sort fields:
- `name`: Alphabetical sorting
- `price`: Price-based sorting  
- `created_at`: Creation date sorting
- `updated_at`: Last modification date sorting

## Response Schemas

### Item Object

```json
{
  "id": 123,
  "name": "Professional Services",
  "description": "Consulting and development services",
  "category": "services",
  "unit_price": 150.00,
  "currency": "USD",
  "tax_rate": 21.0,
  "tax_included": false,
  "sku": "SRV-001",
  "is_available": true,
  "tags": ["consulting", "development"],
  "usage_count": 45,
  "last_used_at": "2024-01-15T10:30:00Z",
  "created_at": "2024-01-01T09:00:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

### Pagination Metadata

```json
{
  "meta": {
    "current_page": 1,
    "total_pages": 10,
    "total_items": 250,
    "per_page": 25,
    "next_page": 2,
    "prev_page": null
  },
  "links": {
    "first": "/api/items?page=1",
    "last": "/api/items?page=10",
    "next": "/api/items?page=2",
    "prev": null
  }
}
```

### Error Response

```json
{
  "error": {
    "code": "validation_error",
    "message": "Validation failed",
    "details": {
      "name": ["has already been taken"],
      "unit_price": ["must be greater than 0"]
    }
  }
}
```

## Error Handling

### HTTP Status Codes

| Code | Description | Common Causes |
|------|-------------|---------------|
| 200 | Success | Request completed successfully |
| 201 | Created | New item created |
| 204 | No Content | Item deleted successfully |
| 400 | Bad Request | Invalid request data |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Item not found |
| 409 | Conflict | Duplicate resource |
| 422 | Unprocessable Entity | Business logic validation failed |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |

### Error Response Format

All error responses follow a consistent format:

```json
{
  "error": {
    "code": "error_code",
    "message": "Human-readable error message",
    "details": {}
  }
}
```

## Integration with Line Items

### Usage Statistics

Each item includes usage statistics:
- `usage_count`: Total times used in invoices
- `last_used_at`: Timestamp of last usage
- Revenue contribution metrics

### Referential Integrity

Items cannot be deleted if they are currently referenced by active line items. The system maintains referential integrity between items and invoice line items.

### Pricing Calculations

When items are used in line items, the following calculations apply:
- Base amount = unit_price × quantity
- Tax amount = base_amount × (tax_rate / 100)
- Total amount = base_amount + tax_amount (or base_amount if tax_included)

## Examples

### Creating an Item

```bash
curl -X POST https://api.example.com/api/items \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "item": {
      "name": "Web Development Service",
      "description": "Custom web application development",
      "category": "development",
      "unit_price": 125.00,
      "currency": "EUR",
      "tax_rate": 21.0,
      "sku": "WEB-DEV-001",
      "is_available": true
    }
  }'
```

### Searching Items

```bash
curl -X GET "https://api.example.com/api/items?search=development&category=services&min_price=100&max_price=200" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Updating Item Pricing

```bash
curl -X PUT https://api.example.com/api/items/123 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "item": {
      "unit_price": 150.00,
      "tax_rate": 23.0
    }
  }'
```

## Best Practices

### Performance Optimization

- Use pagination for large datasets
- Implement client-side caching for frequently accessed items
- Use selective field retrieval when possible
- Leverage ETags for conditional requests

### Data Management

- Maintain consistent naming conventions for categories and tags
- Use SKUs for external system integration
- Keep descriptions concise and informative
- Regularly review and archive unused items

### Security Considerations

- Always validate input data server-side
- Implement rate limiting for API endpoints
- Use HTTPS for all API communications
- Regularly rotate API tokens

### API Design Patterns

- Follow RESTful conventions consistently
- Use appropriate HTTP status codes
- Provide meaningful error messages
- Support versioning for future compatibility