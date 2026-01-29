# Audits1984 JSON API

This document describes the JSON API for programmatic access to Audits1984.

## Authentication

All API requests require authentication via a Bearer token in the `Authorization` header.

### Generating a Token

Tokens are generated through the web interface. An authenticated auditor visits `/auditor_token` and clicks "Generate Token". The plaintext token is displayed once and cannot be retrieved again.

Tokens expire after 1 week. Only one active token exists per auditor; generating a new token invalidates any previous token.

### Using a Token

Include the token in the `Authorization` header:

```
Authorization: Bearer <token>
```

All requests must also include:

```
Accept: application/json
```

### Authentication Errors

| Status | Meaning |
|--------|---------|
| 403 Forbidden | Missing, invalid, or expired token |

## Sessions

### List Sessions

```
GET /sessions
```

Returns a list of console sessions, ordered by creation time (newest first).

#### Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `sensitive_only` | boolean | When `true`, return only sessions that accessed sensitive data |
| `pending_only` | boolean | When `true`, return only sessions with no audits yet |
| `from_date` | date (YYYY-MM-DD) | Return sessions created on or after this date |
| `to_date` | date (YYYY-MM-DD) | Return sessions created on or before this date |

#### Response

```json
{
  "sessions": [
    {
      "id": 123,
      "user": "alice",
      "reason": "Investigating support ticket #456",
      "created_at": "2024-01-15T10:30:00Z",
      "sensitive": true,
      "audit_statuses": ["approved"]
    },
    {
      "id": 124,
      "user": "bob",
      "reason": "Checking permissions",
      "created_at": "2024-01-14T10:30:00Z",
      "sensitive": false,
      "audit_statuses": []
    }
  ]
}
```

#### Session Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Unique session identifier |
| `user` | string or null | Username of the person who ran the console session |
| `reason` | string | The reason provided when starting the console session |
| `created_at` | string (ISO 8601) | When the session was created |
| `sensitive` | boolean | Whether the session accessed any sensitive data |
| `audit_statuses` | array of strings | Status of each audit on this session (empty if unaudited) |

### Show Session

```
GET /sessions/:id
```

Returns detailed information about a single session, including all commands executed and any audits.

#### Response

```json
{
  "session": {
    "id": 123,
    "user": "alice",
    "reason": "Investigating support ticket #456",
    "created_at": "2024-01-15T10:30:00Z",
    "sensitive": true,
    "command_batches": [
      {
        "sensitive": false,
        "justification": null,
        "commands": [
          "User.find(123)",
          "user.name"
        ]
      },
      {
        "sensitive": true,
        "justification": "Need to check payment details",
        "commands": [
          "user.credit_card_number"
        ]
      }
    ],
    "audits": [
      {
        "id": 456,
        "status": "approved",
        "notes": "Legitimate access for support case",
        "auditor_id": 1,
        "created_at": "2024-01-16T09:00:00Z",
        "updated_at": "2024-01-16T09:00:00Z"
      }
    ]
  }
}
```

#### Session Fields (Show)

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Unique session identifier |
| `user` | string or null | Username of the person who ran the console session |
| `reason` | string | The reason provided when starting the console session |
| `created_at` | string (ISO 8601) | When the session was created |
| `sensitive` | boolean | Whether the session accessed any sensitive data |
| `command_batches` | array | Commands grouped by sensitive access context |
| `audits` | array | All audits for this session |

#### Command Batch Fields

Commands are grouped into batches based on sensitive access. Each batch represents a sequence of commands that were either all non-sensitive, or all executed under the same sensitive access justification.

| Field | Type | Description |
|-------|------|-------------|
| `sensitive` | boolean | Whether these commands accessed sensitive data |
| `justification` | string or null | The justification provided for sensitive access (null for non-sensitive batches) |
| `commands` | array of strings | The console commands executed in this batch |

#### Errors

| Status | Response | Meaning |
|--------|----------|---------|
| 404 Not Found | `{"error": "Not found"}` | Session does not exist |

## Audits

### Create Audit

```
POST /sessions/:session_id/audits
```

Creates a new audit for a session. The audit is associated with the authenticated auditor.

#### Request Body

```json
{
  "audit": {
    "status": "approved",
    "notes": "Access was appropriate for the stated reason"
  }
}
```

#### Audit Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string | Yes | One of: `pending`, `approved`, `flagged` |
| `notes` | string | No | Auditor's notes explaining the audit decision |

#### Status Values

| Status | Meaning |
|--------|---------|
| `pending` | Audit has been started but not yet completed |
| `approved` | Session access was appropriate and legitimate |
| `flagged` | Session access was suspicious or inappropriate |

#### Response

Status: 201 Created

```json
{
  "audit": {
    "id": 456,
    "status": "approved",
    "notes": "Access was appropriate for the stated reason",
    "auditor_id": 1,
    "session_id": 123,
    "created_at": "2024-01-16T09:00:00Z",
    "updated_at": "2024-01-16T09:00:00Z"
  }
}
```

#### Errors

| Status | Response | Meaning |
|--------|----------|---------|
| 404 Not Found | `{"error": "Not found"}` | Session does not exist |
| 422 Unprocessable Entity | `{"error": "Validation failed", "messages": [...]}` | Invalid audit parameters |
| 422 Unprocessable Entity | `{"error": "'invalid' is not a valid status"}` | Invalid status value |

### Update Audit

```
PATCH /sessions/:session_id/audits/:id
PUT /sessions/:session_id/audits/:id
```

Updates an existing audit. Only the auditor who created the audit can update it.

#### Request Body

```json
{
  "audit": {
    "status": "flagged",
    "notes": "Upon further review, this access seems suspicious"
  }
}
```

#### Response

Status: 200 OK

```json
{
  "audit": {
    "id": 456,
    "status": "flagged",
    "notes": "Upon further review, this access seems suspicious",
    "auditor_id": 1,
    "session_id": 123,
    "created_at": "2024-01-16T09:00:00Z",
    "updated_at": "2024-01-16T10:00:00Z"
  }
}
```

#### Errors

| Status | Response | Meaning |
|--------|----------|---------|
| 404 Not Found | `{"error": "Not found"}` | Session or audit does not exist |
| 422 Unprocessable Entity | `{"error": "Validation failed", "messages": [...]}` | Invalid audit parameters |

### Audit Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Unique audit identifier |
| `status` | string | The audit status: `pending`, `approved`, or `flagged` |
| `notes` | string or null | Auditor's notes explaining the decision |
| `auditor_id` | integer | ID of the auditor who created/updated the audit |
| `session_id` | integer | ID of the session being audited (only in create/update responses) |
| `created_at` | string (ISO 8601) | When the audit was created |
| `updated_at` | string (ISO 8601) | When the audit was last updated |
