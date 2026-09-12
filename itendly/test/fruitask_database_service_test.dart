import 'dart:convert';

import 'package:attendly/services/fruitask_database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('FruitaskDatabaseService', () {
    test('loads rows and resolves imported dropdown status values', () async {
      final now = DateTime.now();
      final date = _dateOnly(now);
      final responses = <String, List<Map<String, dynamic>>>{
        'students': [
          _row('student-row', {
            'id': 'STU-001',
            'surname': 'MANGANTI',
            'firstname': 'ARDY',
            'middlename': 'TUAZON',
            'active': true,
          }),
          _row('blank-row', const {}),
        ],
        'teachers': [
          _row('teacher-row', {
            'id': 'TCH-001',
            'name': 'Teacher',
            'email': 'teacher@example.com',
            'password': 'secret',
            'active': true,
          }),
        ],
        'sessions': [
          _row('session-row', {
            'id': 'SESSION-001',
            'teacherId': 'dropdown-teacher-option',
            'createdAt': now.subtract(const Duration(minutes: 10)).toIso8601String(),
            'expiresAt': now.add(const Duration(hours: 1)).toIso8601String(),
            'status': 'dropdown-active-option',
          }),
        ],
        'attendance': [
          _row('attendance-1', {
            'id': 'ATT-001',
            'studentId': 'STU-001',
            'sessionId': 'SESSION-001',
            'date': date,
            'timeIn': now.toIso8601String(),
            'status': 'dropdown-present-option',
          }),
          _row('attendance-2', {
            'id': 'ATT-002',
            'studentId': 'STU-002',
            'sessionId': 'SESSION-001',
            'date': date,
            'timeIn': now.add(const Duration(minutes: 1)).toIso8601String(),
            'status': 'dropdown-present-option',
          }),
          _row('attendance-3', {
            'id': 'ATT-003',
            'studentId': 'STU-003',
            'sessionId': 'SESSION-001',
            'date': date,
            'timeIn': 'null',
            'status': 'dropdown-absent-option',
          }),
          _row('attendance-4', {
            'id': 'ATT-004',
            'studentId': 'STU-004',
            'sessionId': 'SESSION-001',
            'date': date,
            'timeIn': now.add(const Duration(minutes: 20)).toIso8601String(),
            'status': 'dropdown-late-option',
          }),
        ],
      };
      final service = FruitaskDatabaseService(
        apiKey: 'test-key',
        workspaceToken: 'test-token',
        client: _readClient(responses),
      );
      addTearDown(service.dispose);

      await service.initialize();

      expect(service.loadError, isNull);
      expect(service.students, hasLength(1));
      expect(service.findStudentById('STU-001')?.displayName, 'ARDY MANGANTI');
      expect(service.activeSession?.teacherId, 'TCH-001');
      expect(service.attendanceRecords.map((record) => record.status),
          ['present', 'present', 'absent', 'late']);
    });

    test('writes a scanned attendance record to Fruitask', () async {
      final now = DateTime.now();
      http.Request? capturedRequest;
      final client = MockClient((request) async {
        expect(request.headers['x-api-key'], 'test-key');
        if (request.method == 'POST') {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {'id': 'remote-attendance-row'},
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        }

        final table = request.url.pathSegments.first;
        final rows = switch (table) {
          'students' => [
              _row('student-row', {
                'id': 'STU-001',
                'surname': 'MANGANTI',
                'firstname': 'ARDY',
                'middlename': 'TUAZON',
                'active': true,
              }),
            ],
          'teachers' => [
              _row('teacher-row', {
                'id': 'TCH-001',
                'name': 'Teacher',
                'email': 'teacher@example.com',
                'password': 'secret',
                'active': true,
              }),
            ],
          'sessions' => [
              _row('session-row', {
                'id': 'SESSION-001',
                'teacherId': 'TCH-001',
                'createdAt': now.toIso8601String(),
                'expiresAt': now.add(const Duration(hours: 1)).toIso8601String(),
                'status': 'active',
              }),
            ],
          _ => <Map<String, dynamic>>[],
        };
        return _rowsResponse(rows);
      });
      final service = FruitaskDatabaseService(
        apiKey: 'test-key',
        workspaceToken: 'test-token',
        client: client,
      );
      addTearDown(service.dispose);
      await service.initialize();

      final record = await service.recordAttendance(
        studentId: 'STU-001',
        sessionId: 'SESSION-001',
      );

      expect(record.studentId, 'STU-001');
      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.url.path,
          '/attendance/test-token/rows');
      final body = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
      expect(body['cells']['studentId'], 'STU-001');
      expect(body['cells']['sessionId'], 'SESSION-001');
      expect(body['cells']['status'], 'present');
    });

    test('reports missing runtime configuration without making requests',
        () async {
      final service = FruitaskDatabaseService(
        apiKey: '',
        workspaceToken: '',
        client: MockClient((_) async => fail('request should not be sent')),
      );
      addTearDown(service.dispose);

      await service.initialize();

      expect(service.isLoaded, isTrue);
      expect(service.loadError, contains('FRUITASK_API_KEY'));
    });
  });
}

MockClient _readClient(Map<String, List<Map<String, dynamic>>> responses) {
  return MockClient((request) async {
    expect(request.method, 'GET');
    expect(request.headers['x-api-key'], 'test-key');
    final table = request.url.pathSegments.first;
    return _rowsResponse(responses[table] ?? const []);
  });
}

http.Response _rowsResponse(List<Map<String, dynamic>> rows) {
  return http.Response(
    jsonEncode({
      'success': true,
      'data': {
        'rows': rows,
        'pagination': {
          'page': 1,
          'limit': 200,
          'totalRows': rows.length,
          'totalPages': 1,
        },
      },
    }),
    200,
    headers: {'content-type': 'application/json'},
  );
}

Map<String, dynamic> _row(String remoteId, Map<String, dynamic> values) {
  return {
    'id': remoteId,
    'cells': {
      for (final entry in values.entries)
        entry.key: {
          'columnName': entry.key,
          'value': entry.value,
          'displayValue': entry.value,
        },
    },
  };
}

String _dateOnly(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
