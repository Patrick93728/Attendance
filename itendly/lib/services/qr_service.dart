import 'dart:convert';

/// Handles QR code payload parsing and validation logic.
///
/// PRODUCTION NOTE: QR validation must also be enforced server-side.
/// The QR payload should be cryptographically signed in production to
/// prevent forgery or replay attacks.
class QrService {
  QrService._();

  static const String _requiredType = 'attendance_session';

  /// Attempts to parse a raw QR code string into a [QrPayload].
  ///
  /// Returns `null` if the payload is not a valid ITENDLY attendance QR.
  static QrPayload? parseQrCode(String rawValue) {
    try {
      final data = jsonDecode(rawValue) as Map<String, dynamic>;

      // Validate required fields
      if (data['type'] != _requiredType) return null;
      if (data['sessionId'] == null) return null;
      if (data['teacherId'] == null) return null;
      if (data['expiresAt'] == null) return null;
      if (data['status'] != 'active') return null;

      return QrPayload(
        type: data['type'] as String,
        sessionId: data['sessionId'] as String,
        teacherId: data['teacherId'] as String,
        createdAt: DateTime.parse(data['createdAt'] as String),
        expiresAt: DateTime.parse(data['expiresAt'] as String),
        embeddedStatus: (data['status'] as String?) ?? 'unknown',
      );
    } catch (_) {
      return null;
    }
  }
}

/// Parsed contents of an ITENDLY attendance QR code.
class QrPayload {
  final String type;
  final String sessionId;
  final String teacherId;
  final DateTime createdAt;
  final DateTime expiresAt;

  /// The status embedded in the QR at generation time.
  /// NOTE: Do NOT use this for validation — always check the live session
  /// status from [MockDatabaseService.validateSession].
  final String embeddedStatus;

  const QrPayload({
    required this.type,
    required this.sessionId,
    required this.teacherId,
    required this.createdAt,
    required this.expiresAt,
    required this.embeddedStatus,
  });

  /// Quick client-side expiry check (not authoritative — server must verify).
  bool get isExpiredByTime => DateTime.now().isAfter(expiresAt);
}
