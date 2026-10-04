# Capstone Project Video Demo Checklist

Use this rubric and step-by-step checklist when recording your final Capstone Project walkthrough video (recommended duration: 3 to 5 minutes).

---

## Pre-Recording Preparation
- [ ] Ensure device / emulator is running at 1080p resolution.
- [ ] Connect microphone and ensure clear voiceover audio.
- [ ] Have Firebase Console open in a browser tab (Authentication & Firestore Database tabs ready).
- [ ] Have terminal open in VS Code ready to run `flutter test`.

---

## Video Walkthrough Checklist

### 1. Introduction & Project Architecture (0:00 - 0:30)
- [ ] State your name and project title: **TaskFlow To-Do Mobile Application**.
- [ ] Briefly show the project folder structure in VS Code:
  - `models/` (Clean data models with validation & serialization)
  - `screens/` (Auth, Task Dashboard, Detail, Add/Edit, Settings)
  - `widgets/` (Reusable UI components)
  - `services/` (Firebase Auth, Cloud Firestore, Notifications, Storage)
  - `providers/` (State management with Provider)

### 2. User Authentication & Error Handling (0:30 - 1:15)
- [ ] Demonstrate input validation on the **Login** and **Sign Up** screens:
  - Attempt sign up with an empty email or invalid password (< 6 characters).
  - Show the user-friendly error banners.
- [ ] Create a new account with email & password.
- [ ] Switch to Firebase Console and refresh the **Authentication** tab to prove the user was created in the cloud.
- [ ] Test the **Log Out** button with the confirmation dialog, then log back in.

### 3. Task Management (CRUD) & Real-time Sync (1:15 - 2:30)
- [ ] **Create Task**:
  - Add a high-priority task with title, description, due date/time, and enable the reminder toggle.
  - Save the task and show it appearing instantly in the dashboard.
- [ ] **Real-time Firestore Verification**:
  - Show the document appearing automatically under `users/{uid}/tasks` in Cloud Firestore.
- [ ] **Mark Completed**:
  - Tap the circular checkbox to toggle completion status.
  - Notice the strike-through and progress metric card updating in real time.
- [ ] **Task Details & Edit**:
  - Tap into the task to view full details (timestamps, urgency, reminders).
  - Edit task priority or title and save changes.
- [ ] **Swipe to Delete**:
  - Swipe task to the left, confirm deletion or demonstrate the Undo SnackBar.

### 4. Search, Filtering & Sorting (2:30 - 3:15)
- [ ] Filter by status: Tap **Pending**, **Completed**, and **All** filter chips.
- [ ] Filter by priority: Open priority menu and select **High** or **Medium**.
- [ ] Search: Tap search icon and type keyword to demonstrate instant filtering.
- [ ] Sort: Change sort order by **Due Date**, **Priority**, or **Creation Date**.

### 5. App Theming & Responsive Design (3:15 - 3:45)
- [ ] Navigate to **Settings & Profile**.
- [ ] Toggle from **Light Mode** to **Dark Mode** and demonstrate crisp Material 3 dark contrast.
- [ ] Switch back or select **System Default**.
- [ ] Show notification permission status and device FCM token.

### 6. Automated Testing & Closing (3:45 - 4:15)
- [ ] Switch to terminal and run the test suite:
  ```bash
  flutter test
  ```
- [ ] Show all unit tests (models, validators) and widget tests passing with 100% green checkmarks.
- [ ] Conclude video with summary of deployment readiness (Android APK/AAB).
