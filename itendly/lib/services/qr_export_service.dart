import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

/// Result of a QR export request.
class QrExportResult {
  final bool saved;
  final String message;

  const QrExportResult({required this.saved, required this.message});
}

/// Captures the rendered QR card and saves it to the public photo gallery.
class QrExportService {
  const QrExportService();

  Future<QrExportResult> saveQrImage(GlobalKey repaintBoundaryKey) async {
    File? temporaryFile;
    try {
      await WidgetsBinding.instance.endOfFrame;
      final renderObject =
          repaintBoundaryKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        return const QrExportResult(
          saved: false,
          message: 'The QR image is not ready yet. Please try again.',
        );
      }

      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) {
          return const QrExportResult(
            saved: false,
            message: 'Gallery permission is required to save QR codes.',
          );
        }
      }

      final image = await renderObject.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) {
        return const QrExportResult(
          saved: false,
          message: 'Failed to encode QR image data.',
        );
      }
      final bytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      temporaryFile = File(
        '${tempDir.path}/ATTENDLY_QR_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await temporaryFile.writeAsBytes(bytes, flush: true);

      await Gal.putImage(temporaryFile.path, album: 'ATTENDLY');

      return const QrExportResult(
        saved: true,
        message: 'QR code saved to Pictures in the ATTENDLY album.',
      );
    } catch (e) {
      debugPrint('QR Save Error: $e');
      return QrExportResult(
        saved: false,
        message: 'Failed to save QR: ${e.toString()}',
      );
    } finally {
      try {
        if (temporaryFile != null && await temporaryFile.exists()) {
          await temporaryFile.delete();
        }
      } catch (error) {
        debugPrint('Unable to remove temporary QR image: $error');
      }
    }
  }
}
