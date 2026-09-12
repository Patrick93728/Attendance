# Fruitask data audit

Audit date: 2026-09-12

The configured Fruitask workspace is named `ATTENDLY`. Read-only API checks
found four tables and 104 total rows:

| Table | Rows | Validity notes |
| --- | ---: | --- |
| `students` | 4 | Three populated rows are all inactive; one row is blank. |
| `teachers` | 1 | The populated teacher is active. |
| `sessions` | 9 | All are historical sessions. |
| `attendance` | 90 | Historical records cover the nine imported sessions. |

## API contract used by the app

- Base URL: `https://integrations.fruitask.com`
- Authentication header: `X-API-Key`
- Workspace metadata: `GET /workspace/{token}/info`
- Workspace tables: `GET /workspace/{token}/tables`
- Paginated rows: `GET /{table}/{token}/rows?page=1&limit=200`
- Create row: `POST /{table}/{token}/rows`
- Update row: `PUT /{table}/{token}/rows/{row_id}`
- Delete row: `DELETE /{table}/{token}/rows/{row_id}`

No API key or workspace token is stored in this repository.

## Required schema alignment

Fruitask currently returns the stored option UUID for dropdown cells instead of
the original label. That makes dropdown-based foreign keys impossible to join
reliably on another device. Configure the tables as follows:

| Table | Columns |
| --- | --- |
| `students` | `id`, `surname`, `firstname`, `middlename`: `short_text`; `active`: `checkbox` |
| `teachers` | `id`, `name`, `password`: `short_text`; `email`: `email`; `active`: `checkbox` |
| `sessions` | `id`, `teacherId`, `createdAt`, `expiresAt`, `status`: `short_text` |
| `attendance` | `id`, `studentId`, `sessionId`, `timeIn`, `status`: `short_text`; `date`: `date` |

The currently incompatible columns are:

- `sessions.teacherId`
- `sessions.status`
- `attendance.studentId`
- `attendance.sessionId`
- `attendance.status`

The app includes best-effort normalization for the imported historical session
and status values, but an opaque historical `attendance.studentId` cannot be
safely assigned to a current student. Change these five columns to text before
using the workspace for live multi-device writes. Also activate the three valid
student rows and remove or complete the blank student row.

## Security note

The direct mobile-to-Fruitask connection is for a controlled prototype only.
Values supplied with `--dart-define` are embedded in the compiled application
and can be extracted. A production deployment needs a server-side proxy,
server-side authorization, hashed teacher passwords, and signed QR/session
validation.
