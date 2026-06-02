# JIT Connect — Developer Setup Guide
## Jahangirabad Institute of Technology · Attendance & Timetable App

---

## Tech Stack
| Layer | Technology |
|---|---|
| Mobile App | Flutter 3.x (Android + iOS) |
| Backend/DB | Firebase Firestore |
| Auth | Firebase Authentication |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| Backend Logic | Firebase Cloud Functions (Node.js 18) |
| File Storage | Firebase Storage |
| State Management | Riverpod 2.x |
| Navigation | GoRouter |
| Charts | fl_chart |

---

## Project Structure
```
jit_connect/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── core/
│   │   ├── constants/app_constants.dart   # All JIT config, courses list
│   │   ├── theme/app_theme.dart           # Dark blue & white theme
│   │   ├── router/app_router.dart         # GoRouter + role-based redirects
│   │   └── utils/                         # Date helpers, validators
│   ├── data/
│   │   ├── models/app_models.dart         # All Firestore data models
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart       # Login, logout, user management
│   │   │   ├── attendance_repository.dart # Mark, submit, fetch attendance
│   │   │   └── timetable_repository.dart  # CRUD timetable slots
│   │   └── services/
│   │       └── notification_service.dart  # FCM + local notifications + buzzer
│   └── presentation/
│       └── screens/
│           ├── auth/login_screen.dart
│           ├── auth/change_password_screen.dart
│           ├── hod/hod_dashboard_screen.dart
│           ├── hod/manage_courses_screen.dart
│           ├── hod/manage_students_screen.dart
│           ├── hod/manage_teachers_screen.dart
│           ├── hod/timetable_builder_screen.dart
│           ├── hod/reports_screen.dart
│           ├── teacher/teacher_dashboard_screen.dart
│           ├── teacher/mark_attendance_screen.dart
│           ├── teacher/extra_class_screen.dart
│           ├── student/student_dashboard_screen.dart
│           └── shared/
│               ├── timetable_screen.dart
│               └── notifications_screen.dart
├── functions/
│   └── index.js                           # All 5 Cloud Functions
├── firestore.rules                        # Security rules
├── firestore.indexes.json                 # Composite indexes
└── pubspec.yaml                           # Flutter dependencies
```

---

## Step 1 — Firebase Project Setup

### 1.1 Create Firebase project
1. Go to https://console.firebase.google.com
2. Create new project: **jit-connect**
3. Enable Google Analytics (optional)

### 1.2 Enable services
In Firebase Console:
- **Authentication** → Sign-in method → Enable **Email/Password**
- **Firestore Database** → Create database → **Production mode**
- **Storage** → Create bucket → Default rules
- **Cloud Messaging** → Already enabled with Firebase

### 1.3 Add apps
- Add **Android** app: package `com.jit.jitconnect`
- Add **iOS** app: bundle ID `com.jit.jitconnect`
- Download `google-services.json` → place in `android/app/`
- Download `GoogleService-Info.plist` → place in `ios/Runner/`

### 1.4 Generate firebase_options.dart
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure (run from project root)
flutterfire configure --project=jit-connect
```
This generates `lib/firebase_options.dart` automatically.

---

## Step 2 — Flutter Setup

### 2.1 Install Flutter
```bash
# Download Flutter SDK from https://flutter.dev
flutter --version   # Should be 3.x+
```

### 2.2 Install dependencies
```bash
cd jit_connect
flutter pub get
```

### 2.3 Add sound asset
Place your class bell sound at:
```
assets/sounds/class_bell.mp3
```
Free sounds: https://freesound.org (search "school bell")

### 2.4 Run the app
```bash
# Android
flutter run

# iOS (Mac only)
flutter run -d ios

# Release build
flutter build apk --release       # Android APK
flutter build appbundle --release  # Android App Bundle (Play Store)
flutter build ipa --release        # iOS IPA
```

---

## Step 3 — Firestore Setup

### 3.1 Deploy security rules
```bash
# Install Firebase CLI
npm install -g firebase-tools
firebase login

# Deploy rules and indexes
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### 3.2 Seed initial data — HOD account
In Firebase Console → Authentication → Add user:
- Email: `hod@jit.edu.in`
- Password: `JIT@2025`

In Firestore → users collection → Add document (ID = Auth UID):
```json
{
  "uid": "<auth-uid>",
  "role": "hod",
  "name": "Dr. Suresh Pandey",
  "employeeId": "JIT-HOD-001",
  "email": "hod@jit.edu.in",
  "phone": "9876543210",
  "isActive": true,
  "mustChangePassword": false,
  "createdAt": "<timestamp>"
}
```

### 3.3 Seed courses
Run this script once in Firebase console (or use the HOD app panel):
```javascript
// Paste in Firebase Console → Functions → Shell
// Or run via Node.js with Admin SDK
const courses = [
  { id: 'bpharm_sem1', name: 'B.Pharm Sem 1', program: 'B.Pharm', semesterOrYear: 'Sem 1', minAttendancePct: 75, academicYear: '2025-26', isActive: true, totalStudents: 0 },
  { id: 'bpharm_sem2', name: 'B.Pharm Sem 2', program: 'B.Pharm', semesterOrYear: 'Sem 2', minAttendancePct: 75, academicYear: '2025-26', isActive: true, totalStudents: 0 },
  { id: 'bpharm_sem3', name: 'B.Pharm Sem 3', program: 'B.Pharm', semesterOrYear: 'Sem 3', minAttendancePct: 75, academicYear: '2025-26', isActive: true, totalStudents: 0 },
  // ... add all 28 courses from app_constants.dart
];
// db.collection('courses').doc(c.id).set(c) for each
```

---

## Step 4 — Cloud Functions Setup

### 4.1 Install dependencies
```bash
cd functions
npm install
```

### 4.2 Deploy functions
```bash
firebase deploy --only functions
```

### 4.3 Verify functions in console
Firebase Console → Functions → should show:
- `onAttendanceSubmit`
- `scheduleClassReminders`
- `onExtraClassApproved`
- `dailyDefaulterCheck`
- `onStudentCreated`

---

## Step 5 — Android Configuration

### android/app/build.gradle
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        applicationId "com.jit.jitconnect"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true
    }
}
dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.4.0'
}
```

### android/app/src/main/res/raw/
Place `class_bell.mp3` here for Android notification sound.

### android/app/src/main/AndroidManifest.xml — add permissions:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

---

## Step 6 — iOS Configuration

### ios/Runner/Info.plist — add:
```xml
<key>NSCalendarsUsageDescription</key>
<string>JIT Connect uses calendar for class scheduling</string>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

---

## Step 7 — First Run Checklist

- [ ] Firebase project created and apps added
- [ ] `google-services.json` in `android/app/`
- [ ] `GoogleService-Info.plist` in `ios/Runner/`
- [ ] `lib/firebase_options.dart` generated via FlutterFire CLI
- [ ] HOD account created in Firebase Auth + Firestore
- [ ] All 28 courses seeded in Firestore `/courses`
- [ ] `firestore.rules` deployed
- [ ] `firestore.indexes.json` deployed
- [ ] Cloud Functions deployed (5 functions)
- [ ] `class_bell.mp3` placed in `assets/sounds/`
- [ ] `flutter pub get` run successfully
- [ ] App builds and runs on device/emulator

---

## Default Login Credentials (Change after first login!)
| Role | Email | Password |
|---|---|---|
| HOD | hod@jit.edu.in | JIT@2025 |
| Teacher (example) | teacher@jit.edu.in | JIT@2025 |
| Student | [enrollment]@jit.edu.in | DDMMYYYY (date of birth) |

---

## Free Tier Limits (Firebase Spark Plan)
| Resource | Free Limit | JIT Estimate |
|---|---|---|
| Firestore reads | 50,000/day | ~5,000/day ✅ |
| Firestore writes | 20,000/day | ~2,000/day ✅ |
| Cloud Functions invocations | 2M/month | ~50K/month ✅ |
| Storage | 5 GB | ~1 GB ✅ |
| FCM Push notifications | Unlimited | ✅ |

**For 300–600 students, free tier is sufficient.**
Upgrade to Blaze (pay-as-you-go) only if usage grows significantly.

---

## Support & Contacts
- Flutter docs: https://docs.flutter.dev
- Firebase docs: https://firebase.google.com/docs
- Riverpod docs: https://riverpod.dev
- GoRouter docs: https://pub.dev/packages/go_router
