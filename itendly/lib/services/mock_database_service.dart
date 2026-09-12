import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/student.dart';
import '../models/teacher.dart';
import '../models/attendance_record.dart';
import '../models/attendance_session.dart';
import 'package:flutter/foundation.dart';

/// Central in-memory data store for the ITENDLY prototype.
///
/// Loads initial data from bundled JSON assets at startup and maintains all
/// state in memory for the duration of the app session.
///
/// PRODUCTION NOTE: Replace this service with a real backend implementation
/// (Firebase, Supabase, REST API, MySQL) by implementing the same public API.
/// No UI screen code needs to change — only this service and [QrService].
class MockDatabaseService extends ChangeNotifier {
  List<Student> _students = [];
  List<Teacher> _teachers = [];
  List<AttendanceRecord> _attendanceRecords = [];
  List<AttendanceSession> _sessions = [];
  bool _isLoaded = false;
  String? _loadError;

  // ─────────────────────────────────────────────
  // Getters
  // ─────────────────────────────────────────────

  List<Student> get students => List.unmodifiable(_students);
  List<Teacher> get teachers => List.unmodifiable(_teachers);
  List<AttendanceRecord> get attendanceRecords =>
      List.unmodifiable(_attendanceRecords);
  List<AttendanceSession> get sessions => List.unmodifiable(_sessions);
  bool get isLoaded => _isLoaded;
  String? get loadError => _loadError;

  /// The currently active session, or null if none exists.
  AttendanceSession? get activeSession {
    try {
      return _sessions.firstWhere((s) => s.isActive);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // Initialization
  // ─────────────────────────────────────────────

  /// Loads all JSON assets into memory from the startup screen.
  Future<void> initialize() async {
    _isLoaded = false;
    _loadError = null;
    notifyListeners();
    try {
      final studentsRaw =
          await rootBundle.loadString('assets/data/mock/students.json');
      final teachersRaw =
          await rootBundle.loadString('assets/data/mock/teachers.json');
      final sessionsRaw =
          await rootBundle.loadString('assets/data/mock/sessions.json');
      final attendanceRaw =
          await rootBundle.loadString('assets/data/mock/attendance.json');

      _students = (jsonDecode(studentsRaw) as List)
          .map((e) => Student.fromJson(e as Map<String, dynamic>))
          .toList();

      _teachers = (jsonDecode(teachersRaw) as List)
          .map((e) => Teacher.fromJson(e as Map<String, dynamic>))
          .toList();

      _sessions = (jsonDecode(sessionsRaw) as List)
          .map((e) => AttendanceSession.fromJson(e as Map<String, dynamic>))
          .toList();

      _attendanceRecords = (jsonDecode(attendanceRaw) as List)
          .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
          .toList();

      _isLoaded = true;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('MockDatabaseService.initialize error: $e\n$stackTrace');
      _loadError = 'Failed to load mock data: $e';
      _isLoaded = true;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────
  // Student Operations
  // ─────────────────────────────────────────────

  /// Looks up a student by exact name match (case-insensitive).
  /// All three name fields must match the active student record.
  Student? findStudentByName(
    String surname,
    String firstname,
    String middlename,
  ) {
    final s = surname.trim().toUpperCase();
    final f = firstname.trim().toUpperCase();
    final m = middlename.trim().toUpperCase();

    try {
      return _students.firstWhere((student) {
        if (!student.active) return false;
        if (student.surname.toUpperCase() != s) return false;
        if (student.firstname.toUpperCase() != f) return false;
        if (student.middlename.toUpperCase() != m) {
          return false;
        }
        return true;
      });
    } catch (_) {
      return null;
    }
  }

  bool isStudentIdAvailable(String studentId, {String? excludingId}) {
    final normalizedId = studentId.trim().toUpperCase();
    return !_students.any(
      (student) =>
          student.id.toUpperCase() == normalizedId &&
          student.id != excludingId,
    );
  }

  bool addStudent(Student student) {
    if (!isStudentIdAvailable(student.id)) return false;
    _students.add(student);
    notifyListeners();
    return true;
  }

  bool updateStudent(String originalId, Student updated) {
    final index = _students.indexWhere((s) => s.id == originalId);
    if (index < 0 ||
        !isStudentIdAvailable(updated.id, excludingId: originalId)) {
      return false;
    }

    _students[index] = updated;
    if (originalId != updated.id) {
      _attendanceRecords = _attendanceRecords
          .map(
            (record) => record.studentId == originalId
                ? AttendanceRecord(
                    id: record.id,
                    studentId: updated.id,
                    sessionId: record.sessionId,
                    date: record.date,
                    timeIn: record.timeIn,
                    status: record.status,
                  )
                : record,
          )
          .toList();
    }
    notifyListeners();
    return true;
  }

  void deleteStudent(String studentId) {
    _students.removeWhere((s) => s.id == studentId);
    notifyListeners();
  }

  /// Generates the next sequential student ID (e.g., STU-011).
  String generateStudentId() {
    final ids = _students
        .map((s) => int.tryParse(s.id.replaceAll('STU-', '')) ?? 0)
        .toList();
    final maxId = ids.isEmpty ? 0 : ids.reduce((a, b) => a > b ? a : b);
    return 'STU-${(maxId + 1).toString().padLeft(3, '0')}';
  }

  // ─────────────────────────────────────────────
  // Teacher Operations
  // ─────────────────────────────────────────────

  /// Validates teacher credentials from the mock database.
  ///
  /// PRODUCTION NOTE: Never validate credentials client-side.
  /// Use a secure server-side authentication endpoint.
  Teacher? loginTeacher(String email, String password) {
    try {
      return _teachers.firstWhere(
        (t) =>
            t.active &&
            t.email.toLowerCase() == email.toLowerCase().trim() &&
            t.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // Session Operations
  // ─────────────────────────────────────────────

  /// Creates a new active session. Ends any currently active session first.
  ///
  /// PRODUCTION NOTE: Session creation and QR generation must be server-side.
  AttendanceSession createSession(String teacherId) {
    // Invalidate all currently active sessions
    for (final session in _sessions) {
      if (session.isActive) {
        session.status = 'ended';
      }
    }

    final now = DateTime.now();
    final newSession = AttendanceSession(
      id: _generateSessionId(now),
      teacherId: teacherId,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 2)),
      status: 'active',
    );

    _sessions.add(newSession);
    notifyListeners();
    return newSession;
  }

  /// Ends the specified session, invalidating its QR immediately.
  void endSession(String sessionId) {
    try {
      final session = _sessions.firstWhere((s) => s.id == sessionId);
      session.status = 'ended';
      notifyListeners();
    } catch (_) {
      // Session not found — ignore silently
    }
  }

  /// Returns the session if it is currently valid and active; null otherwise.
  AttendanceSession? validateSession(String sessionId) {
    try {
      final session = _sessions.firstWhere((s) => s.id == sessionId);
      // Auto-expire if time has passed
      if (session.status == 'active' &&
          DateTime.now().isAfter(session.expiresAt)) {
        session.status = 'expired';
        notifyListeners();
        return null;
      }
      return session.isActive ? session : null;
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // Attendance Operations
  // ─────────────────────────────────────────────

  /// Returns the attendance record for a student in a specific session,
  /// or null if no record exists.
  AttendanceRecord? getAttendanceForStudentSession(
    String studentId,
    String sessionId,
  ) {
    try {
      return _attendanceRecords.firstWhere(
        (r) => r.studentId == studentId && r.sessionId == sessionId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Records a new attendance entry and returns the created record.
  AttendanceRecord recordAttendance({
    required String studentId,
    required String sessionId,
    String status = 'present',
  }) {
    final studentExists =
        _students.any((student) => student.id == studentId && student.active);
    if (!studentExists) {
      throw StateError('Student is not active or does not exist.');
    }
    if (validateSession(sessionId) == null) {
      throw StateError('Attendance session is not active.');
    }
    if (getAttendanceForStudentSession(studentId, sessionId) != null) {
      throw StateError('Attendance has already been recorded.');
    }
    final now = DateTime.now();
    final record = AttendanceRecord(
      id: _generateAttendanceId(),
      studentId: studentId,
      sessionId: sessionId,
      date: DateTime(now.year, now.month, now.day),
      timeIn: now,
      status: status,
    );
    _attendanceRecords.add(record);
    notifyListeners();
    return record;
  }

  /// Returns a student's full attendance history, sorted newest first.
  List<AttendanceRecord> getStudentAttendanceHistory(String studentId) {
    return _attendanceRecords
        .where((r) => r.studentId == studentId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Returns all attendance records for a specific calendar date.
  List<AttendanceRecord> getAttendanceForDate(DateTime date) {
    return _attendanceRecords
        .where(
          (r) =>
              r.date.year == date.year &&
              r.date.month == date.month &&
              r.date.day == date.day,
        )
        .toList();
  }

  /// Returns present/absent/late counts for a student.
  Map<String, int> getStudentAttendanceSummary(String studentId) {
    final history = getStudentAttendanceHistory(studentId);
    return {
      'present': history.where((r) => r.isPresent).length,
      'absent': history.where((r) => r.isAbsent).length,
      'late': history.where((r) => r.isLate).length,
    };
  }

  // ─────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────

  String _generateSessionId(DateTime now) {
    final d = '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final todayCount = _sessions
        .where(
          (s) =>
              s.createdAt.year == now.year &&
              s.createdAt.month == now.month &&
              s.createdAt.day == now.day,
        )
        .length;
    return 'SESSION-$d-${(todayCount + 1).toString().padLeft(3, '0')}';
  }

  String _generateAttendanceId() {
    return 'ATT-${(_attendanceRecords.length + 1).toString().padLeft(3, '0')}';
  }
}
