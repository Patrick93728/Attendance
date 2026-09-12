import 'package:shared_preferences/shared_preferences.dart';

/// Persists only local role identifiers; passwords are never stored.
class DeviceSessionService {
  static const _studentIdKey = 'saved_student_id';
  static const _teacherIdKey = 'saved_teacher_id';

  const DeviceSessionService();

  Future<String?> getStudentId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_studentIdKey);
  }

  Future<String?> getTeacherId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_teacherIdKey);
  }

  Future<void> rememberStudent(String studentId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_studentIdKey, studentId);
    await preferences.remove(_teacherIdKey);
  }

  Future<void> rememberTeacher(String teacherId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_teacherIdKey, teacherId);
  }

  Future<void> clearInvalidStudent() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_studentIdKey);
  }

  Future<void> clearTeacher() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_teacherIdKey);
  }
}
