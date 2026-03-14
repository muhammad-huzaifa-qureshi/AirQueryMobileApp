# Air Query
An **unofficial** mobile app for Air University students to post and answer campus related questions in a smart and organized way.

[![License](https://img.shields.io/badge/License-blue.svg)](LICENSE.md)

# Tech Stack
- Flutter
- Riverpod (for State Management)
- Firebase
- TypeScript (Cloud Functions)
- 
# Firebase Services Used
- Authentication
- Firestore
- Cloud Functions
- Analytics

# Firestore Rules
All Firestore reads and writes are disabled. Use Cloud Functions for all database operations.

# Firestore Database Structure

## Users — `users/{uid}`

| Field             | Type   | Description                                       |
|-------------------|--------|---------------------------------------------------|
| `name`            | String | Display name                                      |
| `campus`          | String | User's campus                                     |
| `semester`        | String | Current semester                                  |
| `queriesPosted`   | Int    | Total queries posted                              |
| `queriesAnswered` | Int    | Total queries answered                            |
| `queriesResolved` | Int    | Total queries marked resolved                     |
| `fcmToken`        | String | For Firebase Cloud Messaging                      |
| `profileComplete` | bool   | True when name, campus and semester is first set. |

## Queries — `queries/{queryId}`

| Field | Type | Description                                 |
|---|---|---------------------------------------------|
| `description` | String | The query content                           |
| `campus` | String | Campus this query belongs to **(can be "All")** |
| `postedBy` | Map | Author info (see below)                     |
| `postedAt` | Timestamp | When the query was posted                   |
| `responseCount` | Int | Total number of responses                   |

**`postedBy` map:**
```
{
  uid:  String   // Author's Firebase UID
  name: String   // Author's display name (denormalized)
}
```

## Responses — `queries/{queryId}/responses/{responseId}`

| Field | Type | Description |
|---|---|---|
| `description` | String | The response content |
| `postedBy` | Map | Author info (see below) |
| `postedAt` | Timestamp | When the response was posted |

**`postedBy` map:**
```
{
  uid:  String   // Author's Firebase UID
  name: String   // Author's display name (denormalized)
}
```

## Platform Stats — `platformStats/global`

| Field | Type | Description |
|---|---|---|
| `totalQueriesPosted` | Int | Total queries posted across all campuses |
| `totalQueriesResolved` | Int | Total queries resolved across all campuses |
| `totalResponses` | Int | Total responses posted across all campuses |


## Notes
- `postedBy.name` is **denormalized** for read efficiency. Name changes will not reflect on old posts by design.
- `responseCount` is **incremented via Cloud Function** on each new response — avoids a full subcollection count query.
- `campus` on each query enables **direct Firestore filtering** without resolving the author's user document.
- Responses are a **subcollection** under each query for natural hierarchy and easy per-query fetching.
- Upon `Resolution`, query will be deleted.

##  Required Firestore Index
### Composite Indexes
```
Collection : queries
Fields     : campus (ASC), postedAt (DESC)
```
```
Collection : queries
Fields     : postedBy.uid (ASC), postedAt (DESC)
```
### Single Field Exemptions
```
Collection Group : responses
Field            : postedBy.uid (ASC)
Scope            : Collection group
```

# What’s Coming Next
- Implement Rate Limiting (high priority)
- Implement a user friendly message when offline rather than current "UNAVAILABLE" error.
- Introduce a **"Report Query"** feature for better moderation
- Add **notifications tab**
- Add **Filters** on Home Feed (like date, response count, etc.)
- Implement **automatic deletion of queries** after 30 days
- Add **profile picture support** for user accounts
- Enhance the overall **user experience** and interaction flow
- Improve the app’s **UI and visual aesthetics**
- Refactor and improve overall **code quality and maintainability**
- Optimize app performance and internal logic

# Disclaimer
This application is an independent project and is **NOT** affiliated with, endorsed by, or officially associated with Air University in any capacity. All references to Air University are for identification purposes only.