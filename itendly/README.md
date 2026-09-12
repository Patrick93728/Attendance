# ITENDLY

ITENDLY is an Android-first Flutter attendance app with student and teacher
flows, QR attendance sessions, student management, persistent device sessions,
and shared attendance data stored through the Fruitask REST API.

## Fruitask configuration

Copy `fruitask.env.example.json` to `fruitask.env.json`, then fill in the API
key and workspace token. The real file is git-ignored.

The workspace must contain `students`, `teachers`, `sessions`, and `attendance`
tables. Identity and status columns must retain their business values. Use
`short_text` for `teacherId`, `studentId`, `sessionId`, and the two `status`
columns; the Fruitask API currently returns opaque option IDs for dropdown
columns, which cannot be joined safely across devices.

The current direct API integration is suitable for a controlled prototype.
Fruitask's own documentation warns against putting an API key or workspace
token in client code. A production build should call a server-side proxy and
store hashed teacher credentials there.

## Run and verify

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run --dart-define-from-file=fruitask.env.json
flutter build apk --release --dart-define-from-file=fruitask.env.json
```

Student, session, and attendance mutations are written to Fruitask. QR image
export captures the rendered QR card, writes a temporary PNG, and saves it to
the public ATTENDLY gallery album.

Student identity is remembered permanently for the device and the student UI
has no logout action. Resetting that binding requires clearing the app's data or
reinstalling it. Teachers can opt into **Remember me** and can always sign out;
teacher logout clears only the saved teacher session.
