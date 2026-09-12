import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:itendly/models/student.dart';
import 'package:itendly/screens/onboarding/role_selection_screen.dart';
import 'package:itendly/services/mock_database_service.dart';
import 'package:itendly/services/qr_service.dart';
import 'package:itendly/widgets/custom_text_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('role selection exposes both entry flows', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: RoleSelectionScreen()),
    );

    expect(find.text('STUDENT'), findsOneWidget);
    expect(find.text('TEACHER'), findsOneWidget);
  });

  test('uppercase formatter transforms typed and pasted names', () {
    const formatter = UpperCaseTextFormatter();
    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(
        text: 'Dela Cruz',
        selection: TextSelection.collapsed(offset: 9),
      ),
    );

    expect(result.text, 'DELA CRUZ');
    expect(result.selection.baseOffset, 9);
  });

  test('QR parser rejects invalid data and accepts attendance payloads', () {
    expect(QrService.parseQrCode('not-json'), isNull);
    expect(
      QrService.parseQrCode(
        '{"type":"other","sessionId":"S-1","teacherId":"T-1",'
        '"createdAt":"2026-09-12T08:00:00",'
        '"expiresAt":"2026-09-12T10:00:00","status":"active"}',
      ),
      isNull,
    );
    expect(
      QrService.parseQrCode(
        '{"type":"attendance_session","sessionId":"S-1",'
        '"teacherId":"T-1","createdAt":"2026-09-12T08:00:00",'
        '"expiresAt":"2099-09-12T10:00:00","status":"ended"}',
      ),
      isNull,
    );

    final payload = QrService.parseQrCode(
      '{"type":"attendance_session","sessionId":"S-1",'
      '"teacherId":"T-1","createdAt":"2026-09-12T08:00:00",'
      '"expiresAt":"2099-09-12T10:00:00","status":"active"}',
    );
    expect(payload?.sessionId, 'S-1');
  });

  group('mock attendance repository', () {
    late MockDatabaseService db;

    setUp(() async {
      db = MockDatabaseService();
      await db.initialize();
      expect(db.loadError, isNull);
    });

    test('new sessions invalidate the previous session', () {
      final teacher = db.teachers.first;
      final first = db.createSession(teacher.id);
      final second = db.createSession(teacher.id);

      expect(first.status, 'ended');
      expect(db.validateSession(first.id), isNull);
      expect(db.validateSession(second.id), same(second));
    });

    test('one student can attend new sessions but not duplicate one', () {
      final teacher = db.teachers.first;
      final student = db.students.first;
      final first = db.createSession(teacher.id);

      db.recordAttendance(studentId: student.id, sessionId: first.id);
      expect(
        () => db.recordAttendance(
          studentId: student.id,
          sessionId: first.id,
        ),
        throwsStateError,
      );

      final second = db.createSession(teacher.id);
      expect(
        () => db.recordAttendance(
          studentId: student.id,
          sessionId: second.id,
        ),
        returnsNormally,
      );
    });

    test('attendance rejects unknown students', () {
      final session = db.createSession(db.teachers.first.id);

      expect(
        () => db.recordAttendance(
          studentId: 'STU-UNKNOWN',
          sessionId: session.id,
        ),
        throwsStateError,
      );
    });

    test('changing a student ID preserves attendance relationships', () {
      final original = db.students.first;
      final previousCount = db.getStudentAttendanceHistory(original.id).length;
      final updated = Student(
        id: 'STU-999',
        surname: original.surname,
        firstname: original.firstname,
        middlename: original.middlename,
      );

      expect(db.updateStudent(original.id, updated), isTrue);
      expect(db.getStudentAttendanceHistory(original.id), isEmpty);
      expect(
          db.getStudentAttendanceHistory(updated.id), hasLength(previousCount));
    });
  });
}
