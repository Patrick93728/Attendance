# ITENDLY

ITENDLY is an Android-first Flutter attendance prototype with student and
teacher flows, QR attendance sessions, student management, and shared in-memory
attendance records loaded from bundled JSON fixtures.

## Demo access

- Teacher email: `teacher@itendly.app`
- Teacher password: `teacher123`
- Example student: `MANGANTI / ARDY / TUAZON`

These credentials are strictly for local UI testing. A production version must
use secure server authentication, hashed passwords, authorization, persistent
storage, and server-side signed QR/session validation.

## Run and verify

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

All mutations are held in memory and reset when the process restarts. QR image
export captures the rendered QR card, writes a temporary PNG with
`path_provider`, and saves it to the public ATTENDLY gallery album.

Student identity is remembered permanently for the device and the student UI
has no logout action. Resetting that binding requires clearing the app's data or
reinstalling it. Teachers can opt into **Remember me** and can always sign out;
teacher logout clears only the saved teacher session.
