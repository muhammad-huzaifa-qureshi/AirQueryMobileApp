# Air Query
An **unofficial** mobile app for Air University students to post and answer campus related questions in a smart and organized way.

[![License](https://img.shields.io/badge/License-blue.svg)](LICENSE.md)

# Tech Stack
- Flutter
- Bloc (for State Management)
- Firebase
- Python (Cloud Functions)
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

| Field | Type | Description |
|---|---|---|
| `uid` | String | Firebase Auth UID |
| `name` | String | Display name |
| `campus` | String | User's campus |
| `semester` | String | Current semester |
| `createdAt` | Timestamp | Account creation time |
| `queriesPosted` | Int | Total queries posted |
| `queriesAnswered` | Int | Total queries answered |
| `queriesResolved` | Int | Total queries marked resolved |
| `profileComplete` | Boolean | Whether profile setup is done |

## Queries — `queries/{queryId}`

| Field | Type | Description |
|---|---|---|
| `description` | String | The query content |
| `campus` | String | Campus this query belongs to |
| `postedBy` | Map | Author info (see below) |
| `postedAt` | Timestamp | When the query was posted |
| `responseCount` | Int | Total number of responses |

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

## Notes
- `postedBy.name` is **denormalized** for read efficiency. Name changes will not reflect on old posts by design.
- `responseCount` is **incremented via Cloud Function** on each new response — avoids a full subcollection count query.
- `campus` on each query enables **direct Firestore filtering** without resolving the author's user document.
- Responses are a **subcollection** under each query for natural hierarchy and easy per-query fetching.
- Upon `Resolution`, query will be deleted.

##  Required Firestore Index
```
Collection : queries
Fields     : campus (ASC), postedAt (DESC)
```

# What’s Coming Next
- Introduce a **"Report Query"** feature for better moderation
- Add **notifications** when a user’s query receives a response
- Implement **automatic deletion of queries** after 30 days
- Introduce **change password** functionality
- Add **profile picture support** for user accounts
- Enhance the overall **user experience** and interaction flow
- Improve the app’s **UI and visual aesthetics**
- Refactor and improve overall **code quality and maintainability**
- Optimize app performance and internal logic

# Disclaimer
This application is an independent project and is **NOT** affiliated with, endorsed by, or officially associated with Air University in any capacity. All references to Air University are for identification purposes only.