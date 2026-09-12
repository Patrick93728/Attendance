# Flutter Attendance Android App --- Coding Agent Prompt

## Role

You are an experienced **Flutter mobile app developer** building a
modern Android attendance application.

Build the application in **Dart using Flutter**.

The attached reference images show the intended visual direction and
basic screen flow. Use them as UI/UX references, but improve the design
so the final application feels modern, clean, responsive, and
production-ready while keeping the same core concept and navigation.

> **Important:** For this phase, focus on the **UI/UX, navigation,
> interactions, validation, and realistic mock data**. Do **not**
> connect to Firebase, MySQL, REST APIs, or another external backend
> yet.

------------------------------------------------------------------------

# 1. Technology Stack

Use:

-   **Flutter**
-   **Dart**
-   Android-first responsive UI
-   Material 3
-   Flutter's built-in navigation/state management unless a package is
    genuinely useful
-   Local mock data stored as **raw JSON files**
-   QR code generation using an appropriate Flutter package
-   QR scanning using an appropriate Flutter package
-   Local JSON/mock repository abstraction so the real backend can be
    plugged in later

Avoid adding unnecessary dependencies.

Recommended project structure:

``` text
lib/
├── main.dart
├── app.dart
├── models/
├── screens/
│   ├── onboarding/
│   ├── student/
│   └── teacher/
├── widgets/
├── services/
│   ├── mock_database_service.dart
│   └── qr_service.dart
├── utils/
├── theme/
└── data/
    └── mock/
        ├── students.json
        ├── teachers.json
        ├── attendance.json
        └── sessions.json
```

------------------------------------------------------------------------

# 2. Main Application Concept

The app is an attendance system called **ITENDLY**.

There are two roles:

1.  **Student**
2.  **Teacher**

The primary attendance flow is:

``` text
Teacher logs in
      ↓
Teacher generates QR code
      ↓
QR represents the active class/session
      ↓
Student opens app
      ↓
Student enters/selects their registered name
      ↓
Student scans active QR
      ↓
Attendance is recorded
      ↓
Student can see their attendance record
      ↓
Teacher can see attendance records
      ↓
Teacher ends session / generates a new QR
      ↓
Previous QR becomes invalid
```

The UI should make this flow very obvious.

------------------------------------------------------------------------

# 3. Reference UI/UX

Use the attached images as visual references.

The reference design contains:

-   White background
-   Blue primary buttons
-   ITENDLY branding
-   Large rounded buttons
-   Simple typography
-   Bottom navigation
-   Student/Teacher role selection
-   Student registration/login-like form
-   Teacher login form
-   Student management list
-   QR generator screen
-   Attendance records screen

Keep the recognizable ITENDLY visual identity, but modernize it.

## Modernization requirements

Use:

-   Material 3 components
-   Rounded cards
-   Proper spacing
-   Clean typography hierarchy
-   Consistent blue primary color
-   Subtle shadows/elevation
-   Modern icons
-   Good empty states
-   Loading states
-   Snackbars/toasts where appropriate
-   Confirmation dialogs for destructive actions
-   Responsive layouts
-   Accessible touch targets
-   Keyboard-safe forms
-   Scrollable content on smaller Android devices

Do not make the interface unnecessarily complicated.

------------------------------------------------------------------------

# 4. App Theme

Create a reusable centralized theme.

Suggested visual direction:

``` text
Primary: ITENDLY blue
Background: very light gray / white
Surface: white
Text: dark navy / near black
Success: green
Warning: amber
Error: red
```

Do not hard-code colors throughout the application.

Create reusable theme constants.

Use a consistent border radius system, for example:

``` text
Small: 8
Medium: 12
Large: 16
XL: 24
```

Use consistent horizontal padding, preferably around 20--24 logical
pixels.

------------------------------------------------------------------------

# 5. Screen 1 --- Role Selection

Create the first screen shown when the app launches.

## Layout

Display:

-   ITENDLY logo/branding near the top-center
-   Short subtitle such as:
    -   `Smart Attendance System`
-   Two large buttons:

``` text
STUDENT
TEACHER
```

Buttons should be:

-   Full-width within a centered container
-   Rounded
-   Blue
-   High contrast
-   Easy to tap
-   Slightly elevated
-   Consistent in size

## Interactions

### Student button

Navigate to the Student identity screen.

### Teacher button

Navigate to the Teacher login screen.

Add subtle page transition animations.

------------------------------------------------------------------------

# 6. Student Registration / Identity Screen

The student flow from the reference contains:

-   Surname
-   Firstname
-   Middlename

Implement these fields.

## Requirements

All name fields should automatically convert typed characters to
uppercase.

Example:

``` text
surname:
MANGANTI

firstname:
ARDY

middlename:
TUAZON
```

Use:

-   `TextCapitalization.characters`
-   Appropriate keyboard configuration
-   Required-field validation
-   Clear labels
-   Modern input styling

Do not use an old-fashioned underline-only input unless it fits the
modern design. Prefer rounded outlined or filled fields.

## Continue button

Add:

``` text
CONTINUE
```

or

``` text
ENTER ATTENDANCE
```

When submitted:

1.  Validate all required fields.
2.  Look for the student in the mock JSON database.
3.  If the student exists:
    -   Load the student data.
    -   Open Student Home.
4.  If the student does not exist:
    -   Show a clear message.
    -   Do not silently create a duplicate.
    -   Optionally provide a mock registration flow if implemented.

Example message:

``` text
Student not found.

Please check your name or contact your teacher.
```

The student should not be allowed into the attendance home screen unless
the student exists in the mock database.

------------------------------------------------------------------------

# 7. Teacher Login Screen

The Teacher login screen should contain:

-   Email
-   Password
-   Login button

Use proper password masking.

Example mock/default account:

``` text
Email:
teacher@itendly.app

Password:
teacher123
```

These credentials are for UI/mockup testing only.

Do not describe them as secure production credentials.

## Login behavior

If credentials match the mock teacher JSON:

``` text
Open Teacher Home
```

Otherwise:

``` text
Invalid email or password.
```

Add loading state when pressing Login.

------------------------------------------------------------------------

# 8. Student Home

The Student Home should use a modern bottom navigation bar.

Required tabs:

``` text
Scan
Records
```

Optionally include:

``` text
Home/Profile
```

if it improves UX, but keep the required tabs prominent.

------------------------------------------------------------------------

# 9. Student --- Scan Tab

This is the main attendance screen.

Display:

-   ITENDLY branding/header
-   Welcome message using the student's name
-   Attendance status card
-   QR scanner button/view
-   Session information

Example:

``` text
Good morning, ARDY!

Attendance
Not yet recorded

Scan the class QR code to mark your attendance.
```

## QR scanning

Implement a real QR scanner UI using an appropriate Flutter package.

The scanner should:

1.  Open camera permission request.
2.  Detect QR code.
3.  Read the QR payload.
4.  Validate the session.
5.  Confirm that the session is active.
6.  Prevent duplicate attendance.
7.  Save attendance to mock attendance data/state.

Display success:

``` text
Attendance Recorded

ARDY MANGANTI
Present
Today • 8:03 AM
```

Display invalid QR:

``` text
Invalid QR Code

This class session is no longer active.
```

Display duplicate attendance:

``` text
Already Recorded

Your attendance for this session has already been recorded.
```

------------------------------------------------------------------------

# 10. Student --- Records Tab

Create an attendance history screen.

Display:

-   Student name
-   Current attendance summary
-   Attendance history
-   Date
-   Time
-   Status
-   Class/session information if available

Example:

``` text
Attendance Summary

Present     18
Absent       2
Late         1
```

Then a list:

``` text
September 11, 2026
Present
8:03 AM

September 10, 2026
Present
8:01 AM

September 9, 2026
Absent
—
```

Use cards or clean list tiles.

Add filtering if practical:

-   All
-   Present
-   Absent
-   Late

------------------------------------------------------------------------

# 11. Teacher Home

Teacher navigation must contain:

``` text
Students
QR Generator
Records
```

Use a modern bottom navigation bar.

The teacher's name and basic information may appear in the top app bar
or profile area.

------------------------------------------------------------------------

# 12. Teacher --- Students Tab

This screen manages students.

Required operations:

-   Add
-   Update
-   Delete

The reference image shows a list with edit and delete icons.

Modernize it into cards/list tiles.

Example:

``` text
ARDY MANGANTI
Student ID: STU-001

[Edit] [Delete]
```

Floating action button:

``` text
+
```

opens Add Student.

## Add Student

Fields:

``` text
Surname
Firstname
Middlename
Student ID
```

Automatically uppercase name fields.

Validate required fields.

Save the new student into the in-memory mock database.

For this prototype, persistence may be simulated through the
repository/state layer rather than modifying bundled JSON files at
runtime.

## Edit Student

Allow updating:

-   Name
-   Student ID

## Delete Student

Show confirmation:

``` text
Delete student?

This will remove the student from the current mock data.

Cancel
Delete
```

Do not delete immediately without confirmation.

------------------------------------------------------------------------

# 13. Teacher --- QR Generator Tab

This is a core feature.

The screen should contain:

-   Current class/session information
-   QR code preview
-   Session status
-   Generate button
-   End session button
-   Download/save QR action

Example:

``` text
Class Attendance

BSIT 4-5
Today's Session

Session Active

[ QR CODE ]

Session expires when the class session ends.

GENERATE NEW QR
END SESSION
SAVE QR
```

## QR behavior

Every generated QR should represent a unique attendance session.

Example mock QR payload:

``` json
{
  "type": "attendance_session",
  "sessionId": "SESSION-20260911-001",
  "teacherId": "TCH-001",
  "createdAt": "2026-09-11T08:00:00",
  "expiresAt": "2026-09-11T10:00:00",
  "status": "active"
}
```

Do not put sensitive information inside the QR.

The student scanner should only accept a QR that:

-   Has the correct attendance QR type
-   Has a valid session ID
-   Has not expired
-   Has status `active`

------------------------------------------------------------------------

# 14. QR Session Expiration

This is an important requirement.

The QR generated for a class should NOT remain valid forever.

Implement session validation with:

``` text
createdAt
expiresAt
status
sessionId
```

When the teacher ends a session:

``` text
status = ended
```

The QR must immediately become invalid.

When a new QR is generated:

-   Create a new session ID.
-   Previous active session becomes invalid/ended.
-   New QR becomes active.

Example:

``` text
SESSION-001 → ended
SESSION-002 → active
```

This should be represented in the mock database.

------------------------------------------------------------------------

# 15. Teacher --- Records Tab

The teacher must be able to view attendance records.

Required controls:

``` text
TODAY
DATE
```

The reference image uses Today and Date buttons.

Implement a date picker for selecting a specific date.

## Today view

Show all attendance records for the current date.

Example:

``` text
Today's Attendance

ARDY TUAZON MANGANTI     Present
JUAN DELA CRUZ           Present
MARIA SANTOS             Absent
PEDRO REYES              Late
```

Use status colors/icons consistently.

## Specific date

Allow the teacher to select another date.

Then filter the records from mock attendance JSON.

Example:

``` text
September 10, 2026

ARDY TUAZON MANGANTI     Present
JUAN DELA CRUZ           Absent
MARIA SANTOS             Present
```

------------------------------------------------------------------------

# 16. Attendance Data Model

Create clear Dart models.

Example:

``` dart
class AttendanceRecord {
  final String id;
  final String studentId;
  final String sessionId;
  final DateTime date;
  final DateTime? timeIn;
  final String status;
}
```

Possible statuses:

``` text
present
absent
late
```

Create models for:

``` text
Student
Teacher
AttendanceRecord
AttendanceSession
```

------------------------------------------------------------------------

# 17. Mock JSON Database

Use raw JSON files.

Create:

## students.json

Example:

``` json
[
  {
    "id": "STU-001",
    "surname": "MANGANTI",
    "firstname": "ARDY",
    "middlename": "TUAZON",
    "active": true
  },
  {
    "id": "STU-002",
    "surname": "DELA CRUZ",
    "firstname": "JUAN",
    "middlename": "SANTOS",
    "active": true
  }
]
```

## teachers.json

``` json
[
  {
    "id": "TCH-001",
    "name": "Teacher Demo",
    "email": "teacher@itendly.app",
    "password": "teacher123",
    "active": true
  }
]
```

## sessions.json

``` json
[
  {
    "id": "SESSION-20260911-001",
    "teacherId": "TCH-001",
    "createdAt": "2026-09-11T08:00:00",
    "expiresAt": "2026-09-11T10:00:00",
    "status": "active"
  }
]
```

## attendance.json

``` json
[
  {
    "id": "ATT-001",
    "studentId": "STU-001",
    "sessionId": "SESSION-20260911-001",
    "date": "2026-09-11",
    "timeIn": "2026-09-11T08:03:00",
    "status": "present"
  }
]
```

Add enough mock records to make the UI look realistic.

Include multiple dates and different statuses.

------------------------------------------------------------------------

# 18. Mock Database Architecture

Do not directly read JSON inside every screen.

Create a service/repository layer.

For example:

``` dart
class MockDatabaseService {
  Future<List<Student>> getStudents();
  Future<List<Teacher>> getTeachers();
  Future<List<AttendanceRecord>> getAttendanceRecords();
  Future<List<AttendanceSession>> getSessions();

  Future<Student?> findStudentByName(...);
  Future<Teacher?> loginTeacher(...);

  Future<void> addStudent(Student student);
  Future<void> updateStudent(Student student);
  Future<void> deleteStudent(String studentId);

  Future<void> createAttendanceRecord(AttendanceRecord record);

  Future<AttendanceSession?> getActiveSession();
  Future<void> endSession(String sessionId);
}
```

For the prototype, maintain changes in memory during the app session.

Keep the repository interface clean so it can later be replaced by:

``` text
Firebase
REST API
MySQL backend
Supabase
```

without rewriting the UI.

------------------------------------------------------------------------

# 19. Attendance Business Rules

Implement these rules.

## Rule 1 --- Student must exist

A student cannot access attendance features unless their identity exists
in the mock student database.

## Rule 2 --- QR must be valid

The scanner must reject:

-   Invalid QR format
-   Unknown session
-   Expired session
-   Ended session

## Rule 3 --- One attendance per student per session

A student cannot submit the same attendance twice for the same session.

## Rule 4 --- Session expiration

An expired session automatically becomes invalid.

## Rule 5 --- Teacher ends session

Ending a session immediately invalidates its QR.

## Rule 6 --- New QR

Generating a new session invalidates the previous active session.

## Rule 7 --- Attendance records

When valid scanning occurs:

``` text
Student record → Present
Teacher record → Present
```

Both views should read from the same mock attendance data source.

------------------------------------------------------------------------

# 20. Student Scenario

Implement this exact scenario.

``` text
Student opens app
        ↓
Select STUDENT
        ↓
Enter:
Surname
Firstname
Middlename
        ↓
Validate student against mock database
        ↓
If student does not exist
        ↓
Show "Student not found"
        ↓
If student exists
        ↓
Open Student Home
        ↓
Student scans teacher's QR
        ↓
Validate session
        ↓
If valid
        ↓
Save attendance
        ↓
Show Present confirmation
        ↓
Attendance appears in Student Records
        ↓
Attendance appears in Teacher Records
```

If there is no active class/session, clearly communicate:

``` text
No Active Class

There is currently no active attendance session.
Ask your teacher to generate a QR code.
```

------------------------------------------------------------------------

# 21. Teacher Scenario

Implement:

``` text
Teacher opens app
        ↓
Select TEACHER
        ↓
Login
        ↓
Teacher Home
        ↓
Generate QR
        ↓
Active session created
        ↓
Students scan QR
        ↓
Attendance records created
        ↓
Teacher opens Records
        ↓
See today's attendance
        ↓
Select another date
        ↓
See historical attendance
```

------------------------------------------------------------------------

# 22. QR Download / Save

The teacher should have a button to save/download the generated QR.

Implement the UI and actual local image-saving behavior if practical
with an appropriate Flutter package.

If Android storage permissions make the implementation unnecessarily
complex for this prototype, keep a working mock action and clearly
isolate it behind a service method for later completion.

The UI should still include:

``` text
SAVE QR
```

and provide feedback:

``` text
QR code saved successfully.
```

------------------------------------------------------------------------

# 23. Navigation

Use clean route/navigation architecture.

Recommended route names:

``` text
/
 /role-selection
 /student/identity
 /student/home
 /student/scan
 /student/records
 /teacher/login
 /teacher/home
 /teacher/students
 /teacher/qr
 /teacher/records
```

Bottom navigation should preserve tab state where appropriate.

Do not allow unnecessary navigation stack duplication when switching
tabs.

------------------------------------------------------------------------

# 24. Reusable Widgets

Create reusable components such as:

``` text
AppLogo
PrimaryButton
SecondaryButton
CustomTextField
AttendanceStatusCard
StudentListTile
AttendanceRecordTile
QrDisplayCard
EmptyState
LoadingIndicator
ConfirmationDialog
```

Avoid duplicating UI code.

------------------------------------------------------------------------

# 25. Error and Empty States

Design proper states for:

-   No students
-   No attendance records
-   No active QR session
-   Invalid QR
-   Expired QR
-   Duplicate attendance
-   Student not found
-   Invalid teacher login
-   Camera permission denied
-   QR scanner error
-   Empty date result

Do not leave blank screens.

------------------------------------------------------------------------

# 26. Loading States

Add loading states for:

-   Student validation
-   Teacher login
-   Loading JSON
-   Generating QR
-   Saving attendance
-   Student CRUD operations

Use short simulated delays if needed to make the prototype feel
realistic, but do not add unnecessary artificial delays.

------------------------------------------------------------------------

# 27. Animations

Use subtle animations only.

Recommended:

-   Fade/slide between major screens
-   Button press feedback
-   QR generation transition
-   Success check animation
-   List item insertion/removal

Avoid excessive animations.

------------------------------------------------------------------------

# 28. Responsive Design

The app must work on common Android phone sizes.

Test mentally and/or with Flutter tooling for:

``` text
Small phones
Medium phones
Large phones
```

Avoid:

-   Overflow errors
-   Fixed-height layouts that break
-   Text clipping
-   Buttons too close to screen edges
-   Keyboard covering fields

Forms should use `SafeArea` and scrolling where necessary.

------------------------------------------------------------------------

# 29. Security Note for Prototype

This is a UI/mockup prototype.

Do not pretend that storing a teacher password in raw JSON is secure.

Add comments/documentation that production implementation should use:

-   Secure authentication
-   Password hashing
-   Backend validation
-   Server-side QR/session validation
-   Proper authorization
-   Database persistence

The current JSON password exists only for local demo/testing.

------------------------------------------------------------------------

# 30. UI Copy

Use clear, simple wording.

Prefer:

``` text
Scan QR Code
Attendance Recorded
No Active Class
Invalid QR Code
Already Recorded
Student Not Found
Generate QR
End Session
Today's Attendance
Select Date
Add Student
Update Student
Delete Student
```

Avoid overly technical messages for end users.

------------------------------------------------------------------------

# 31. Suggested Student Home UI

Example structure:

``` text
┌──────────────────────────────┐
│ ITENDLY               ⋮      │
│                              │
│ Good morning, ARDY!          │
│                              │
│ ┌──────────────────────────┐ │
│ │ Today's Attendance       │ │
│ │                          │ │
│ │ NOT YET RECORDED         │ │
│ └──────────────────────────┘ │
│                              │
│       ┌──────────────┐       │
│       │   QR SCAN    │       │
│       └──────────────┘       │
│                              │
│ Scan your teacher's QR code  │
│ to mark your attendance.     │
│                              │
├──────────────────────────────┤
│   Scan              Records  │
└──────────────────────────────┘
```

This is only a conceptual layout. Improve it visually.

------------------------------------------------------------------------

# 32. Suggested Teacher QR UI

``` text
┌──────────────────────────────┐
│ ITENDLY                      │
│                              │
│ Class Attendance             │
│ BSIT 4-5                     │
│                              │
│        ┌─────────────┐       │
│        │             │       │
│        │   QR CODE   │       │
│        │             │       │
│        └─────────────┘       │
│                              │
│ ● SESSION ACTIVE             │
│ Expires: 10:00 AM            │
│                              │
│ [ Generate New QR ]          │
│ [ Save QR ]                  │
│ [ End Session ]              │
│                              │
├──────────────────────────────┤
│ Students  QR Generator  Records │
└──────────────────────────────┘
```

------------------------------------------------------------------------

# 33. Suggested Teacher Records UI

Use a clean dashboard-like layout:

``` text
Attendance Records

[ Today ] [ Select Date ]

Present     Absent     Late
  18           2        1

────────────────────────

ARDY TUAZON MANGANTI
8:03 AM                         Present

JUAN DELA CRUZ
—                               Absent

MARIA SANTOS
8:15 AM                         Late
```

Use badges instead of relying only on colors.

------------------------------------------------------------------------

# 34. Code Quality Requirements

Write clean, maintainable Dart.

Requirements:

-   Null safety
-   Strong typing
-   Small reusable widgets
-   Meaningful variable names
-   No unnecessary global variables
-   No duplicated business logic
-   Avoid huge `build()` methods
-   Separate UI from mock database logic
-   Use constants for repeated UI values
-   Add comments only where useful
-   Handle errors gracefully

Do not put the entire application inside `main.dart`.

------------------------------------------------------------------------

# 35. Deliverables

Generate a complete Flutter prototype containing:

1.  Working Flutter Android application
2.  Role selection
3.  Student identity form
4.  Teacher login
5.  Student home
6.  Student QR scanner
7.  Student attendance records
8.  Teacher student management
9.  Teacher QR generator
10. QR session expiration
11. Teacher attendance records
12. Mock JSON database
13. Dart models
14. Mock database/repository service
15. Reusable widgets
16. Modern Material 3 theme
17. Navigation
18. Validation
19. Error/empty/loading states
20. QR generation and scanning
21. Mock attendance synchronization between student and teacher views

------------------------------------------------------------------------

# 36. Implementation Order

Build in this order:

### Phase 1 --- Foundation

-   Flutter project setup
-   Theme
-   App structure
-   Models
-   Mock JSON files
-   Mock repository

### Phase 2 --- Authentication / Entry

-   Role selection
-   Student identity
-   Teacher login

### Phase 3 --- Student

-   Student home
-   Scan screen
-   QR scanner
-   Attendance validation
-   Records

### Phase 4 --- Teacher

-   Teacher home
-   Student CRUD
-   QR generator
-   Session management
-   Records/date filtering

### Phase 5 --- Polish

-   Animations
-   Empty states
-   Error handling
-   Loading states
-   Responsive improvements
-   Accessibility
-   Final UI consistency

------------------------------------------------------------------------

# 37. Important Coding-Agent Instructions

Before writing code:

1.  Inspect the existing Flutter project structure.
2.  Do not unnecessarily delete existing working files.
3.  Reuse existing dependencies when possible.
4.  Check `pubspec.yaml` before adding packages.
5.  Keep the implementation compatible with the project's current
    Flutter/Dart version.
6.  Use the attached ITENDLY screenshots as visual references.
7.  Implement the complete navigation flow rather than isolated static
    screens.
8.  Make the UI functional with mock data.
9.  Keep the mock database architecture replaceable.
10. Do not connect to a real backend yet.

After implementation:

1.  Run formatting.
2.  Run static analysis.
3.  Fix analyzer errors and warnings where practical.
4.  Run available tests.
5.  Verify all routes and buttons.
6.  Verify QR generation.
7.  Verify QR scanning.
8.  Verify session expiration logic.
9.  Verify duplicate attendance prevention.
10. Verify student and teacher records reflect the same attendance data.

------------------------------------------------------------------------

# 38. Definition of Done

The prototype is complete when this end-to-end test works:

``` text
1. Open app
2. Select Teacher
3. Login using mock teacher account
4. Generate QR
5. Confirm session is active
6. Return/restart as Student
7. Enter a student existing in students.json
8. Open Student Home
9. Scan the active teacher QR
10. Attendance becomes Present
11. Student Records shows the attendance
12. Teacher Records shows the same attendance
13. Try scanning the same QR again
14. Duplicate attendance is rejected
15. End the teacher session
16. Try scanning the old QR
17. QR is rejected as expired/ended
18. Generate a new QR
19. New QR is accepted for a new attendance session
20. Teacher can view records by Today and selected Date
```

The final result should feel like a **real modern Android attendance
application**, not just a collection of static screens.

Keep the design inspired by the supplied ITENDLY references while
significantly improving spacing, hierarchy, usability, feedback states,
and overall polish.
