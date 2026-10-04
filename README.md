# TaskFlow — Production Flutter To-Do Application with Firebase

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)](https://firebase.google.com/)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

**TaskFlow** is a complete, production-grade To-Do mobile application built with Flutter and Firebase, engineered according to the **Week 4 Capstone Project & Deployment** specifications.

---

## 🌟 Key Features

### 🔐 1. User Authentication
* **Email & Password Authentication**: Powered by Firebase Authentication.
* **Input Validation**: Real-time email formatting, minimum password length (6+ chars), password matching confirmation.
* **Session Persistence**: Secure, automatic session restoration across application restarts.
* **Password Reset**: Self-service password recovery email dispatcher.
* **Informative Errors**: Translated Firebase error codes into actionable user messages.

### 📝 2. Full Task Management (CRUD)
* **Create, Read, Update, Delete**: Comprehensive task handling with titles, descriptions, due dates, times, priority levels, and reminders.
* **Priority Levels**: Color-coded `Low`, `Medium`, and `High` priorities.
* **Completion Status**: Instant toggling between Completed and Pending with dynamic strike-through styling.
* **Due Date Tracking**: Smart indicators highlighting overdue tasks and tasks due today.
* **Swipe-to-Delete**: Dismissible task cards with safety confirmation and Undo action.

### ⚡ 3. Firebase Cloud Firestore Integration
* **Real-Time Synchronization**: Instant data streaming via Firestore queries (`StreamBuilder` / Provider).
* **Strict User Isolation**: Scoped subcollection hierarchy (`users/{userId}/tasks/{taskId}`) ensuring zero unauthorized data leaks.
* **Security Rules**: Production-ready `firestore.rules` preventing cross-user reads, writes, and modifications.
* **Offline Persistence**: Default Firestore local caching for seamless offline operations.

### 🎨 4. Modern UI & Theming (Material 3)
* **Light & Dark Mode**: Dynamic theme switching with persistent user preference using `SharedPreferences`.
* **Metric Overview Dashboard**: Dynamic progress bar and task statistics (Total, Completed, Pending, Overdue).
* **Search & Filters**:
  * Status filtering: `All`, `Pending`, `Completed`.
  * Priority filtering: `Low`, `Medium`, `High`.
  * Real-time search query matching title and description.
  * Sorting options: Due Date, Priority, Date Created, Alphabetical.
* **Responsive Layout**: Fluid layout supporting diverse Android screen sizes and densities.

### 🔔 5. Notifications & Reminders
* **Scheduled Local Reminders**: Timezone-aware local alarms for upcoming deadlines (`flutter_local_notifications`).
* **Firebase Cloud Messaging (FCM)**: Push notification reception and device token inspection tool.
* **Reboot Resilience**: Boot receivers to reschedule pending alarms upon device restarts.

### 🧪 6. Testing Suite
* Complete unit tests for models (`TaskModel`, serialization, overdue calculations).
* Input validator unit tests (`AppValidators` covering email, password, and task titles).
* Widget tests verifying priority badges, empty states, and user interaction callbacks.

---

## 📁 Project Architecture

```
flutter_todo_capstone/
├── android/                         # Android platform configuration
│   ├── app/
│   │   ├── build.gradle             # App-level build config (desugaring, minSdk 21, multidex)
│   │   ├── google-services.json     # Firebase Android configuration file
│   │   └── src/main/
│   │       └── AndroidManifest.xml  # Permissions (Notifications, Alarms, Boot)
│   ├── build.gradle                 # Root project build config (Google Services plugin)
│   ├── settings.gradle
│   └── key.properties.example       # Keystore release signing template
├── lib/
│   ├── main.dart                    # Application entry point & Provider initialization
│   ├── firebase_options.dart        # Multiplatform Firebase options configuration
│   ├── models/
│   │   ├── task_model.dart          # Task entity with Firestore serialization & copyWith
│   │   ├── priority_enum.dart       # TaskPriority enum (low, medium, high) with colors & icons
│   │   └── user_model.dart          # AppUser entity
│   ├── services/
│   │   ├── auth_service.dart        # Firebase Auth wrapper & error handling
│   │   ├── firestore_service.dart   # Firestore CRUD & user-scoped streams
│   │   ├── notification_service.dart# Scheduled notifications & FCM setup
│   │   └── storage_service.dart     # SharedPreferences persistence (theme, settings)
│   ├── providers/
│   │   ├── auth_provider.dart       # Authentication state management
│   │   ├── task_provider.dart       # Task state, filtering, sorting, and metrics
│   │   └── theme_provider.dart      # Dynamic Light / Dark mode state
│   ├── screens/
│   │   ├── splash_screen.dart       # Auth session router
│   │   ├── auth/
│   │   │   ├── login_screen.dart    # Login & Password reset screen
│   │   │   └── signup_screen.dart   # Registration screen
│   │   ├── tasks/
│   │   │   ├── task_list_screen.dart# Main task dashboard with metrics & filters
│   │   │   ├── task_detail_screen.dart# Detailed task inspection & deletion
│   │   │   └── add_edit_task_screen.dart# Task creation and editing form
│   │   └── settings/
│   │       └── settings_screen.dart # Theme toggle, notification check, logout
│   ├── widgets/
│   │   ├── task_card.dart           # Reusable swipeable task card
│   │   ├── task_stats_card.dart     # Progress bar and stats counter widget
│   │   ├── task_filter_bar.dart     # Tab chips for All/Pending/Completed
│   │   ├── priority_badge.dart      # Visual priority pill badge
│   │   ├── custom_text_field.dart   # Validated input field
│   │   ├── custom_button.dart       # Button with built-in loading indicator
│   │   ├── confirm_dialog.dart      # Safe confirmation modal
│   │   └── empty_state_view.dart    # Empty list placeholder
│   └── utils/
│       ├── app_theme.dart           # Material 3 light and dark theme definitions
│       ├── constants.dart           # Global constants & collection names
│       ├── date_formatter.dart      # Human-friendly date formatting
│       └── validators.dart          # Form input validation logic
├── test/                            # Unit & Widget Test Suite
│   ├── models/
│   │   └── task_model_test.dart
│   ├── utils/
│   │   └── validators_test.dart
│   └── widgets/
│       ├── priority_badge_test.dart
│       └── empty_state_test.dart
├── firestore.rules                  # Firestore production security rules
├── firestore.indexes.json           # Composite database indexes
├── pubspec.yaml                     # Dependencies and project metadata
├── README.md                        # Project documentation
├── FIREBASE_SETUP.md                # Step-by-step Firebase Console instructions
├── DEPLOYMENT_GUIDE.md              # Android APK/AAB build & Play Store guide
└── DEMO_CHECKLIST.md                # Video walkthrough recording script & rubric
```

---

## 🚀 Quickstart Installation & Execution

### 1. Prerequisites
* **Flutter SDK**: `>= 3.2.0` ([Install Flutter](https://docs.flutter.dev/get-started/install))
* **Java JDK**: `17` or `21`
* **Android Studio** with Android SDK Command-line Tools and Platform-Tools installed.

### 2. Configure Workspace
Open the project directory:
```bash
cd flutter_todo_capstone
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Configure Firebase
Follow the detailed steps in [FIREBASE_SETUP.md](./FIREBASE_SETUP.md) to link your Firebase project or run:
```bash
flutterfire configure
```

### 5. Run the Application
Launch an Android emulator or connect a physical device, then run:
```bash
flutter run
```

---

## 🧪 Running Automated Tests

Run the full unit and widget test suite:
```bash
flutter test
```

To run with coverage analysis:
```bash
flutter test --coverage
```

---

## 📦 Android Build & Deployment

### Build Debug APK (For immediate testing on physical devices)
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Build Signed Release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Build Android App Bundle (For Google Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

For keystore setup and Play Console preparation, see [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md).

---

## 🎥 Demo Video Rubric
Follow the recording script and checklist in [DEMO_CHECKLIST.md](./DEMO_CHECKLIST.md) to capture your submission video.
