# Firebase Configuration & Setup Guide

This guide walks you through connecting **TaskFlow** to your Firebase project.

---

## 1. Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** (or **Create a project**).
3. Name your project (e.g., `todo-capstone-app`).
4. (Optional) Enable Google Analytics and click **Create Project**.

---

## 2. Enable Firebase Authentication

1. In the Firebase Console left sidebar, click **Build > Authentication**.
2. Click **Get Started**.
3. Under the **Sign-in method** tab:
   - Select **Email/Password**.
   - Toggle **Enable** to ON.
   - Leave "Email link (passwordless sign-in)" OFF.
   - Click **Save**.

---

## 3. Configure Cloud Firestore Database

1. In the Firebase Console, navigate to **Build > Firestore Database**.
2. Click **Create database**.
3. Choose your database location (choose a region closest to your users, e.g., `us-central1` or `asia-south1`).
4. Select **Start in production mode** and click **Create**.

### Database Structure
The application employs strict user isolation using subcollections:
```
users/ (collection)
 └── {userId} (document: uid, email, displayName, createdAt)
      └── tasks/ (subcollection)
           └── {taskId} (document)
                ├── id: string
                ├── userId: string
                ├── title: string
                ├── description: string
                ├── dueDate: timestamp (or null)
                ├── priority: "low" | "medium" | "high"
                ├── isCompleted: boolean
                ├── reminderSet: boolean
                ├── createdAt: timestamp
                └── updatedAt: timestamp
```

### Apply Security Rules
1. In Firestore, click the **Rules** tab.
2. Copy the contents of [`firestore.rules`](./firestore.rules) and paste them into the editor:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    match /users/{userId} {
      allow read, write: if isOwner(userId);
      
      match /tasks/{taskId} {
        allow read, write, delete: if isOwner(userId);
      }
    }

    match /{document=**} {
      allow read, write: false;
    }
  }
}
```
3. Click **Publish**.

---

## 4. Android App Registration & Configuration

### Option A: Automated Configuration (Recommended)
1. Install the Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```
2. Log into Firebase:
   ```bash
   firebase login
   ```
3. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
4. Run configuration inside the project directory:
   ```bash
   flutterfire configure
   ```
   Select your Firebase project and check **Android** (and any other platforms you want). This automatically updates `lib/firebase_options.dart` and `android/app/google-services.json`.

---

### Option B: Manual Configuration
1. In the Firebase Console Project Overview, click the **Android** icon to add an app.
2. Enter the Android package name:
   ```
   com.example.flutter_todo_capstone
   ```
3. (Optional) Enter App nickname: `TaskFlow`.
4. (Optional) Provide Debug SHA-1 signing certificate fingerprint:
   ```powershell
   keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```
5. Click **Register app**.
6. Download `google-services.json`.
7. Move `google-services.json` to:
   ```
   android/app/google-services.json
   ```
8. Update `lib/firebase_options.dart` with your project credentials:
   - `apiKey`
   - `appId`
   - `messagingSenderId`
   - `projectId`

---

## 5. Enable Firebase Cloud Messaging (FCM)

1. In the Firebase Console, go to **Project Settings > Cloud Messaging**.
2. Ensure **Firebase Cloud Messaging API (V1)** is enabled.
3. To test push notifications:
   - Launch the application and open **Settings & Profile**.
   - Tap **View FCM Token** and copy the device registration token.
   - In the Firebase Console, go to **Engage > Messaging**.
   - Click **Create your first campaign > Firebase Notification messages**.
   - Enter title and body, then click **Send test message** and paste your device FCM token.
