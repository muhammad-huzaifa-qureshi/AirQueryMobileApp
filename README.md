# Air Query
An **unofficial** mobile app for Air University students to post and answer campus related questions in a smart and organized way.

[![Get it on Google Play](https://img.shields.io/badge/Download-Google%20Play-34A853?style=for-the-badge&logo=google-play&logoColor=white)](https://play.google.com/store/apps/details?id=com.hqapplications.airuniversity.airquery)

[![License](https://img.shields.io/badge/License-Air%20Query-111111?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](LICENSE.md)

[![Privacy Policy](https://img.shields.io/badge/Privacy-Policy-2563EB?style=for-the-badge&logo=shield&logoColor=white)](https://sites.google.com/view/air-query-privacy-policy/air-query)

[![Delete Account](https://img.shields.io/badge/Account-Data%20Deletion-DC2626?style=for-the-badge&logo=trash&logoColor=white)](https://forms.gle/DmUXGR4ZAqZQ9szJA)

# Tech Stack
- Flutter
- Riverpod (for State Management)
- Firebase
- TypeScript (Cloud Functions)

# Firebase Services Used
- Authentication
- Firestore
- Cloud Functions
- Analytics
- App Check
- Cloud Messaging (FCM)
- Storage

# Firestore Structure

## `users/{uid}`
- `name`: String
- `campus`: String
- `semester`: String
- `queriesPosted`: Int
- `responsesPosted`: Int
- `queriesResolved`: Int
- `profileComplete`: Bool

## `users/{uid}/private/fcmToken`
- `token`: String

## `users/{uid}/rateLimits/limits`
- `profileLastUpdated`: Timestamp
- `queryLastPostedAt`: Timestamp
- `queryDailyCount`: Int
- `responseLastPostedAt`: Timestamp
- `responseDailyCount`: Int

## `queries/{queryId}`
- `description`: String
- `campus`: String — user's campus or `"All"`
- `postedBy`: Map — `{ uid: String, name: String }`
- `postedAt`: Timestamp
- `responseCount`: Int
- `isResolved`: bool
- `imagePath`: String | null

## `queries/{queryId}/responses/{responseId}`
- `description`: String
- `postedBy`: Map — `{ uid: String, name: String }`
- `postedAt`: Timestamp
- `mentionedUid`: string | null
- `mentionedName`: string | null

## `platformStats/global`
- `totalQueriesPosted`: Int
- `totalQueriesResolved`: Int
- `totalResponses`: Int

## `fcmTokens/{campus}`
- Each document key is a `uid` of a user in that campus.
- The value for each `uid` is the FCM token string.

# What’s Coming Next
- Query reporting system
- Skeleton loading (shimmer effect) on home feed
- Fix navigation issue when opening responses from notifications (missing back option)
- Firebase Crashlytics integration for crash monitoring
- Dedicated notifications tab
- Home feed filters (date, response count, etc.)
- Automatic query deletion after 30 days
- Improved user experience and interaction flow
- UI and visual design enhancements
- Codebase refactoring for better maintainability
- Performance and internal logic optimizations

# Contributing & Local Setup

> Assumes familiarity with Flutter, Firebase, and TypeScript. Not a beginner guide.

## Prerequisites
- Flutter & Dart SDK
- Node.js
- Firebase CLI — `npm install -g firebase-tools`

## 1. Clone & Install
```bash
git clone https://github.com/muhammad-huzaifa-qureshi/AirQueryMobileApp
cd AirQueryMobileApp
flutter pub get
```

## 2. Firebase Setup
Create your own Firebase project and enable the following services:
- listed above in [Firebase Services Used](#firebase-services-used)

Then follow Firebase guidelines to add a **Flutter App**.
DO NOT commit any sensitive file.

## 3. Firestore Rules & Indexes
Deploy the included rules and indexes:
```bash
firebase deploy --only firestore:rules,firestore:indexes
```

## 4. Storage Rules
Deploy the included rules:
```bash
firebase deploy --only storage
```

## 5. Cloud Functions
```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

## 6. App Check
Enable App Check in Firebase Console with **Play Integrity** (Android). For development, register your debug token under App Check → Apps → Manage debug tokens.

## 7. Run
```bash
flutter run
```
or by using Android Studio.

> **Note:** iOS is not actively maintained — no guarantee of compatibility without additional configuration.

# Disclaimer
This application is an independent project and is **NOT** affiliated with, endorsed by, or officially associated with Air University in any capacity. All references to Air University are for identification purposes only.

# Contact
Before starting work on a new feature, **reach out first** — open a GitHub discussion or email `muhammadhuzaifaqureshi01@gmail.com`. This avoids duplicate effort and ensures the feature aligns with the project direction. Bug fixes and improvements are welcome directly via PR.

For any technical issues or questions regarding the codebase, feel free to reach out via email or open a GitHub issue.