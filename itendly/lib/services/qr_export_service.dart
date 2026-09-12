/// Result of a QR export request.
class QrExportResult {
  final bool saved;
  final String message;

  const QrExportResult({required this.saved, required this.message});
}

/// Boundary for replacing the prototype export with Android image persistence.
class QrExportService {
  const QrExportService();

  Future<QrExportResult> saveQrImage(String qrData) async {
    // Prototype fallback: image persistence intentionally remains isolated here.
    // A production implementation should render [qrData], request the scoped
    // Android permission when needed, and save through MediaStore.
    return const QrExportResult(
      saved: false,
      message: 'QR saving is a prototype preview and is not available yet.',
    );
  }
}
