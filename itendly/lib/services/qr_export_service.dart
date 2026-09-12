import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:gal/gal.dart';

/// Result of a QR export request.
class QrExportResult {
  final bool saved;
  final String message;

  const QrExportResult({required this.saved, required this.message});
}

/// Actually generates and saves the QR image to the user's gallery using `gal`.
class QrExportService {
  const QrExportService();

  Future<QrExportResult> saveQrImage(String qrData) async {
    try {
      // 1. Ask for permission (Gal handles the dialog internally if needed)
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          return const QrExportResult(
            saved: false,
            message: 'Gallery permission is required to save QR codes.',
          );
        }
      }

      // 2. Render QR code to an image
      final painter = QrPainter(
        data: qrData,
        version: QrVersions.auto,
        gapless: true,
        color: const Color(0xFF0D2E4D),
        emptyColor: Colors.white,
      );

      // Create a picture and draw a white background first
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      const size = 512.0;
      final paint = Paint()..color = Colors.white;
      canvas.drawRect(const Rect.fromLTWH(0, 0, size, size), paint);
      
      // Draw the QR
      painter.paint(canvas, const Size(size, size));
      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());

      // 3. Convert to bytes
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return const QrExportResult(
          saved: false,
          message: 'Failed to encode QR image data.',
        );
      }
      final bytes = byteData.buffer.asUint8List();

      // 4. Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/ATTENDLY_QR_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      // 5. Save to gallery via Gal
      await Gal.putImage(file.path);

      return const QrExportResult(
        saved: true,
        message: 'QR code saved to your gallery successfully.',
      );
    } catch (e) {
      debugPrint('QR Save Error: $e');
      return QrExportResult(
        saved: false,
        message: 'Failed to save QR: ${e.toString()}',
      );
    }
  }
}
