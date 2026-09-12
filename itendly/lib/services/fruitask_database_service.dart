import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/attendance_record.dart';
import '../models/attendance_session.dart';
import '../models/student.dart';
import '../models/teacher.dart';

class FruitaskApiException implements Exception {
  final String message;
  final int? statusCode;

  const FruitaskApiException(this.message, {this.statusCode});

  @override
  String toString() => statusCode == null
      ? 'FruitaskApiException: $message'
      : 'FruitaskApiException ($statusCode): $message';
}

/// Fruitask-backed attendance repository.
///
/// Credentials are intentionally read from compile-time environment values so
/// they never need to be committed to the repository. A mobile binary cannot
/// keep an API key secret, so production deployments should put Fruitask behind
/// a small authenticated server endpoint and rotate any client-exposed key.
class FruitaskDatabaseService extends ChangeNotifier {
  static const _baseUrl = 'https://integrations.fruitask.com';
  static const _requestTimeout = Duration(seconds: 20);

  final String apiKey;
  final String workspaceToken;
  final http.Client _client;

  List<Student> _students = [];
  List<Teacher> _teachers = [];
  List<AttendanceRecord> _attendanceRecords = [];
  List<AttendanceSession> _sessions = [];
  bool _isLoaded = false;
  String? _loadError;
  final Map<String, String> _studentRows = {};
  final Map<String, String> _sessionRows = {};
  final Map<String, String> _attendanceRows = {};

  FruitaskDatabaseService({
    required this.apiKey,
    required this.workspaceToken,
    http.Client? client,
  }) : _client = client ?? http.Client();

  factory FruitaskDatabaseService.fromEnvironment({http.Client? client}) {
    return FruitaskDatabaseService(
      apiKey: const String.fromEnvironment('FRUITASK_API_KEY'),
      workspaceToken:
          const String.fromEnvironment('FRUITASK_WORKSPACE_TOKEN'),
      client: client,
    );
  }

  List<Student> get students => List.unmodifiable(_students);
  List<Teacher> get teachers => List.unmodifiable(_teachers);
  List<AttendanceRecord> get attendanceRecords =>
      List.unmodifiable(_attendanceRecords);
  List<AttendanceSession> get sessions => List.unmodifiable(_sessions);
  bool get isLoaded => _isLoaded;
  String? get loadError => _loadError;

  AttendanceSession? get activeSession {
    try {
      return _sessions.lastWhere((session) => session.isActive);
    } catch (_) {
      return null;
    }
  }

  Future<void> initialize() async {
    _isLoaded = false;
    _loadError = null;
    notifyListeners();

    if (apiKey.trim().isEmpty || workspaceToken.trim().isEmpty) {
      _loadError = 'Fruitask is not configured. Start the app with '
          'FRUITASK_API_KEY and FRUITASK_WORKSPACE_TOKEN dart-defines.';
      _isLoaded = true;
      notifyListeners();
      return;
    }

    try {
      final responses = await Future.wait([
        _getRows('students'),
        _getRows('teachers'),
        _getRows('sessions'),
        _getRows('attendance'),
      ]);

      _loadStudents(responses[0]);
      _loadTeachers(responses[1]);
      _loadSessions(responses[2]);
      _loadAttendance(responses[3]);
      _isLoaded = true;
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('Fruitask initialization failed: $error\n$stackTrace');
      _loadError = error is FruitaskApiException
          ? error.message
          : 'Unable to load attendance data from Fruitask.';
      _isLoaded = true;
      notifyListeners();
    }
  }

  Student? findStudentByName(
    String surname,
    String firstname,
    String middlename,
  ) {
    final normalizedSurname = surname.trim().toUpperCase();
    final normalizedFirstname = firstname.trim().toUpperCase();
    final normalizedMiddlename = middlename.trim().toUpperCase();
    try {
      return _students.firstWhere(
        (student) =>
            student.active &&
            student.surname.toUpperCase() == normalizedSurname &&
            student.firstname.toUpperCase() == normalizedFirstname &&
            student.middlename.toUpperCase() == normalizedMiddlename,
      );
    } catch (_) {
      return null;
    }
  }

  Student? findStudentById(String studentId) {
    try {
      return _students.firstWhere(
        (student) => student.id == studentId && student.active,
      );
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

  Future<bool> addStudent(Student student) async {
    if (!isStudentIdAvailable(student.id)) return false;
    final row = await _createRow('students', student.toJson());
    final remoteId = _remoteRowId(row);
    if (remoteId != null) _studentRows[student.id] = remoteId;
    _students.add(student);
    notifyListeners();
    return true;
  }

  Future<bool> updateStudent(String originalId, Student updated) async {
    final index = _students.indexWhere((student) => student.id == originalId);
    final rowId = _studentRows[originalId];
    if (index < 0 ||
        rowId == null ||
        !isStudentIdAvailable(updated.id, excludingId: originalId)) {
      return false;
    }

    await _updateRow('students', rowId, updated.toJson());
    _students[index] = updated;
    _studentRows.remove(originalId);
    _studentRows[updated.id] = rowId;
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

  Future<bool> deleteStudent(String studentId) async {
    final rowId = _studentRows[studentId];
    if (rowId == null) return false;
    await _deleteRow('students', rowId);
    _studentRows.remove(studentId);
    _students.removeWhere((student) => student.id == studentId);
    notifyListeners();
    return true;
  }

  String generateStudentId() {
    final ids = _students
        .map((student) =>
            int.tryParse(student.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
    final maxId = ids.isEmpty ? 0 : ids.reduce((a, b) => a > b ? a : b);
    return 'STU-${(maxId + 1).toString().padLeft(3, '0')}';
  }

  Teacher? loginTeacher(String email, String password) {
    try {
      return _teachers.firstWhere(
        (teacher) =>
            teacher.active &&
            teacher.email.toLowerCase() == email.toLowerCase().trim() &&
            teacher.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  Teacher? findTeacherById(String teacherId) {
    try {
      return _teachers.firstWhere(
        (teacher) => teacher.id == teacherId && teacher.active,
      );
    } catch (_) {
      return null;
    }
  }

  Future<AttendanceSession> createSession(String teacherId) async {
    final currentSession = activeSession;
    if (currentSession != null) await endSession(currentSession.id);

    final now = DateTime.now();
    final session = AttendanceSession(
      id: _generateSessionId(now),
      teacherId: teacherId,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 2)),
      status: 'active',
    );
    final row = await _createRow('sessions', session.toJson());
    final remoteId = _remoteRowId(row);
    if (remoteId != null) _sessionRows[session.id] = remoteId;
    _sessions.add(session);
    notifyListeners();
    return session;
  }

  Future<void> endSession(String sessionId) async {
    final index = _sessions.indexWhere((session) => session.id == sessionId);
    final rowId = _sessionRows[sessionId];
    if (index < 0 || rowId == null) return;
    final session = _sessions[index];
    final endedAt = DateTime.now();
    await _updateRow('sessions', rowId, {
      'status': 'ended',
      'expiresAt': endedAt.toIso8601String(),
    });
    _sessions[index] = AttendanceSession(
      id: session.id,
      teacherId: session.teacherId,
      createdAt: session.createdAt,
      expiresAt: endedAt,
      status: 'ended',
    );
    notifyListeners();
  }

  AttendanceSession? validateSession(String sessionId) {
    try {
      final session = _sessions.firstWhere((item) => item.id == sessionId);
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

  AttendanceRecord? getAttendanceForStudentSession(
    String studentId,
    String sessionId,
  ) {
    try {
      return _attendanceRecords.firstWhere(
        (record) =>
            record.studentId == studentId && record.sessionId == sessionId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<AttendanceRecord> recordAttendance({
    required String studentId,
    required String sessionId,
    String status = 'present',
  }) async {
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
    final row = await _createRow('attendance', record.toJson());
    final remoteId = _remoteRowId(row);
    if (remoteId != null) _attendanceRows[record.id] = remoteId;
    _attendanceRecords.add(record);
    notifyListeners();
    return record;
  }

  List<AttendanceRecord> getStudentAttendanceHistory(String studentId) {
    return _attendanceRecords
        .where((record) => record.studentId == studentId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<AttendanceRecord> getAttendanceForDate(DateTime date) {
    return _attendanceRecords
        .where(
          (record) =>
              record.date.year == date.year &&
              record.date.month == date.month &&
              record.date.day == date.day,
        )
        .toList();
  }

  Map<String, int> getStudentAttendanceSummary(String studentId) {
    final history = getStudentAttendanceHistory(studentId);
    return {
      'present': history.where((record) => record.isPresent).length,
      'absent': history.where((record) => record.isAbsent).length,
      'late': history.where((record) => record.isLate).length,
    };
  }

  void _loadStudents(List<Map<String, dynamic>> rows) {
    _studentRows.clear();
    _students = [];
    for (final row in rows) {
      final id = _stringCell(row, 'id');
      final surname = _stringCell(row, 'surname');
      final firstname = _stringCell(row, 'firstname');
      if (id == null || surname == null || firstname == null) continue;
      _studentRows[id] = row['id'] as String;
      _students.add(
        Student(
          id: id,
          surname: surname,
          firstname: firstname,
          middlename: _stringCell(row, 'middlename') ?? '',
          active: _boolCell(row, 'active'),
        ),
      );
    }
  }

  void _loadTeachers(List<Map<String, dynamic>> rows) {
    _teachers = [];
    for (final row in rows) {
      final id = _stringCell(row, 'id');
      final name = _stringCell(row, 'name');
      final email = _stringCell(row, 'email');
      final password = _stringCell(row, 'password');
      if (id == null || name == null || email == null || password == null) {
        continue;
      }
      _teachers.add(
        Teacher(
          id: id,
          name: name,
          email: email,
          password: password,
          active: _boolCell(row, 'active'),
        ),
      );
    }
  }

  void _loadSessions(List<Map<String, dynamic>> rows) {
    _sessionRows.clear();
    _sessions = [];
    for (final row in rows) {
      final id = _stringCell(row, 'id');
      final createdAt = _dateTimeCell(row, 'createdAt');
      final expiresAt = _dateTimeCell(row, 'expiresAt');
      if (id == null || createdAt == null || expiresAt == null) continue;
      final rawTeacherId = _stringCell(row, 'teacherId');
      final teacherId = _teachers.any((item) => item.id == rawTeacherId)
          ? rawTeacherId!
          : (_teachers.length == 1 ? _teachers.single.id : rawTeacherId ?? '');
      final rawStatus = _stringCell(row, 'status');
      final status = const {'active', 'ended', 'expired'}.contains(rawStatus)
          ? rawStatus!
          : (DateTime.now().isBefore(expiresAt) ? 'active' : 'ended');
      _sessionRows[id] = row['id'] as String;
      _sessions.add(
        AttendanceSession(
          id: id,
          teacherId: teacherId,
          createdAt: createdAt,
          expiresAt: expiresAt,
          status: status,
        ),
      );
    }
  }

  void _loadAttendance(List<Map<String, dynamic>> rows) {
    _attendanceRows.clear();
    _attendanceRecords = [];
    final inferredStatuses = _inferAttendanceStatuses(rows);
    final sessionIdsByDate = <String, String>{
      for (final session in _sessions)
        _dateOnly(session.createdAt): session.id,
    };

    for (final row in rows) {
      final id = _stringCell(row, 'id');
      final date = _dateTimeCell(row, 'date');
      if (id == null || date == null) continue;
      final rawSessionId = _stringCell(row, 'sessionId');
      final sessionId = _sessions.any((item) => item.id == rawSessionId)
          ? rawSessionId!
          : sessionIdsByDate[_dateOnly(date)] ?? rawSessionId ?? '';
      final rawStatus = _stringCell(row, 'status');
      final status = const {'present', 'absent', 'late'}.contains(rawStatus)
          ? rawStatus!
          : inferredStatuses[rawStatus] ?? 'present';
      final timeIn = _dateTimeCell(row, 'timeIn');
      _attendanceRows[id] = row['id'] as String;
      _attendanceRecords.add(
        AttendanceRecord(
          id: id,
          studentId: _stringCell(row, 'studentId') ?? '',
          sessionId: sessionId,
          date: DateTime(date.year, date.month, date.day),
          timeIn: timeIn,
          status: timeIn == null ? 'absent' : status,
        ),
      );
    }
  }

  Map<String, String> _inferAttendanceStatuses(
    List<Map<String, dynamic>> rows,
  ) {
    final counts = <String, int>{};
    final absentValues = <String>{};
    for (final row in rows) {
      final rawStatus = _stringCell(row, 'status');
      if (rawStatus == null) continue;
      if (_dateTimeCell(row, 'timeIn') == null) {
        absentValues.add(rawStatus);
      } else {
        counts[rawStatus] = (counts[rawStatus] ?? 0) + 1;
      }
    }
    final ordered = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {
      for (final value in absentValues) value: 'absent',
      if (ordered.isNotEmpty) ordered.first.key: 'present',
      for (final entry in ordered.skip(1)) entry.key: 'late',
    };
  }

  Future<List<Map<String, dynamic>>> _getRows(String table) async {
    const pageSize = 200;
    var page = 1;
    final result = <Map<String, dynamic>>[];
    while (true) {
      final response = await _send(
        'GET',
        _tableUri(
          table,
          'rows',
          query: {'page': '$page', 'limit': '$pageSize'},
        ),
      );
      final data = response['data'];
      final rows = data is Map<String, dynamic> ? data['rows'] : null;
      if (rows is! List) {
        throw const FruitaskApiException(
          'Fruitask returned an invalid row list.',
        );
      }
      result.addAll(
        rows
            .whereType<Map>()
            .map((row) => row.cast<String, dynamic>()),
      );
      final pagination = data is Map ? data['pagination'] : null;
      final totalPages = pagination is Map && pagination['totalPages'] is num
          ? (pagination['totalPages'] as num).toInt()
          : page;
      if (page >= totalPages || rows.length < pageSize) break;
      page++;
    }
    return result;
  }

  Future<Map<String, dynamic>> _createRow(
    String table,
    Map<String, dynamic> cells,
  ) async {
    final response = await _send(
      'POST',
      _tableUri(table, 'rows'),
      body: {'cells': cells},
    );
    final row = _responseRow(response);
    if (_remoteRowId(row) != null) return row;

    final businessId = cells['id']?.toString();
    if (businessId == null) return row;
    final rows = await _getRows(table);
    try {
      return rows.lastWhere((candidate) =>
          _stringCell(candidate, 'id') == businessId);
    } catch (_) {
      return row;
    }
  }

  Future<void> _updateRow(
    String table,
    String rowId,
    Map<String, dynamic> cells,
  ) async {
    await _send(
      'PUT',
      _tableUri(table, 'rows/$rowId'),
      body: {'cells': cells},
    );
  }

  Future<void> _deleteRow(String table, String rowId) async {
    await _send('DELETE', _tableUri(table, 'rows/$rowId'));
  }

  Uri _tableUri(
    String table,
    String suffix, {
    Map<String, String>? query,
  }) {
    return Uri.parse(
      '$_baseUrl/${Uri.encodeComponent(table)}/'
      '${Uri.encodeComponent(workspaceToken)}/$suffix',
    ).replace(queryParameters: query);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
  }) async {
    final request = http.Request(method, uri)
      ..headers.addAll({
        'X-API-Key': apiKey,
        'Accept': 'application/json',
        if (body != null) 'Content-Type': 'application/json',
      });
    if (body != null) request.body = jsonEncode(body);

    final streamed = await _client.send(request).timeout(_requestTimeout);
    final response = await http.Response.fromStream(streamed);
    Map<String, dynamic> decoded = {};
    if (response.body.trim().isNotEmpty) {
      final value = jsonDecode(response.body);
      if (value is Map) decoded = value.cast<String, dynamic>();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded['message']?.toString() ??
          'Fruitask request failed (${response.statusCode}).';
      throw FruitaskApiException(message, statusCode: response.statusCode);
    }
    return decoded;
  }

  Map<String, dynamic> _responseRow(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map) {
      final map = data.cast<String, dynamic>();
      final row = map['row'];
      if (row is Map) return row.cast<String, dynamic>();
      return map;
    }
    return const {};
  }

  String? _remoteRowId(Map<String, dynamic> row) {
    final value = row['id'];
    return value is String && value.isNotEmpty ? value : null;
  }

  dynamic _cellValue(Map<String, dynamic> row, String name) {
    final cells = row['cells'];
    if (cells is! Map) return null;
    final cell = cells[name];
    return cell is Map ? cell['value'] : cell;
  }

  String? _stringCell(Map<String, dynamic> row, String name) {
    final value = _cellValue(row, name);
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty || text.toLowerCase() == 'null' ? null : text;
  }

  bool _boolCell(Map<String, dynamic> row, String name) {
    final value = _cellValue(row, name);
    if (value is bool) return value;
    return value?.toString().toLowerCase() == 'true';
  }

  DateTime? _dateTimeCell(Map<String, dynamic> row, String name) {
    final value = _stringCell(row, name);
    return value == null ? null : DateTime.tryParse(value);
  }

  String _dateOnly(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  String _generateSessionId(DateTime now) {
    final date = '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final todayCount = _sessions
        .where((session) => _dateOnly(session.createdAt) == _dateOnly(now))
        .length;
    return 'SESSION-$date-${(todayCount + 1).toString().padLeft(3, '0')}';
  }

  String _generateAttendanceId() {
    final maxId = _attendanceRecords
        .map((record) =>
            int.tryParse(record.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .fold<int>(0, (current, value) => value > current ? value : current);
    return 'ATT-${(maxId + 1).toString().padLeft(3, '0')}';
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}
