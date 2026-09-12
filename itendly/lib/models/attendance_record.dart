/// Represents a single attendance entry for a student in a session.
class AttendanceRecord {
  final String id;
  final String studentId;
  final String sessionId;

  /// The calendar date of the attendance (time component stripped)
  final DateTime date;

  /// Actual time the student checked in; null for absent records
  final DateTime? timeIn;

  /// One of: 'present', 'absent', 'late'
  final String status;

  const AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.sessionId,
    required this.date,
    this.timeIn,
    required this.status,
  });

  bool get isPresent => status == 'present';
  bool get isAbsent => status == 'absent';
  bool get isLate => status == 'late';

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      sessionId: json['sessionId'] as String,
      date: DateTime.parse(json['date'] as String),
      timeIn: json['timeIn'] != null
          ? DateTime.parse(json['timeIn'] as String)
          : null,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'sessionId': sessionId,
      'date':
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'timeIn': timeIn?.toIso8601String(),
      'status': status,
    };
  }

  @override
  bool operator ==(Object other) => other is AttendanceRecord && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AttendanceRecord($id, student=$studentId, status=$status)';
}
