import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class CustomMarkerService {
  static final Map<String, BitmapDescriptor> _markerCache = {};

  static Future<BitmapDescriptor> createMarkerWithImage({
    required String imageUrl,
    int size = 120,
    Color borderColor = Colors.white,
    double borderWidth = 4,
  }) async {
    final cacheKey = '${imageUrl}_$size';
    if (_markerCache.containsKey(cacheKey)) {
      return _markerCache[cacheKey]!;
    }

    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        return BitmapDescriptor.defaultMarker;
      }

      final Uint8List imageBytes = response.bodyBytes;
      final ui.Codec codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: size,
        targetHeight: size,
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      final paint = Paint();

      final double radius = size / 2;
      final Offset center = Offset(radius, radius);

      paint.color = borderColor;
      canvas.drawCircle(center, radius, paint);

      final Path clipPath = Path()
        ..addOval(Rect.fromCircle(
          center: center,
          radius: radius - borderWidth,
        ));
      canvas.clipPath(clipPath);

      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(
          borderWidth,
          borderWidth,
          size - borderWidth * 2,
          size - borderWidth * 2,
        ),
        paint,
      );

      final ui.Image markerAsImage =
          await pictureRecorder.endRecording().toImage(size, size);

      final ByteData? byteData = await markerAsImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List markerBytes = byteData!.buffer.asUint8List();

      final bitmapDescriptor = BitmapDescriptor.fromBytes(markerBytes);

      _markerCache[cacheKey] = bitmapDescriptor;

      return bitmapDescriptor;
    } catch (e) {
      debugPrint('Error creating custom marker: $e');
      return BitmapDescriptor.defaultMarker;
    }
  }

  static Future<BitmapDescriptor> createMarkerWithImageAndTransport({
    required String imageUrl,
    required IconData transportIcon,
    int size = 120,
    Color borderColor = Colors.white,
    double borderWidth = 4,
  }) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        return BitmapDescriptor.defaultMarker;
      }

      final Uint8List imageBytes = response.bodyBytes;
      final ui.Codec codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: size,
        targetHeight: size,
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      final paint = Paint();

      final double radius = size / 2;
      final Offset center = Offset(radius, radius);

      paint.color = borderColor;
      canvas.drawCircle(center, radius, paint);

      final Path clipPath = Path()
        ..addOval(Rect.fromCircle(
          center: center,
          radius: radius - borderWidth,
        ));
      canvas.clipPath(clipPath);

      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(
          borderWidth,
          borderWidth,
          size - borderWidth * 2,
          size - borderWidth * 2,
        ),
        paint,
      );

      canvas.restore();

      final iconSize = size * 0.3;
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(transportIcon.codePoint),
          style: TextStyle(
            fontSize: iconSize,
            fontFamily: transportIcon.fontFamily,
            color: Colors.blue,
            backgroundColor: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      iconPainter.layout();
      iconPainter.paint(
        canvas,
        Offset(
          size - iconSize - 5,
          size - iconSize - 5,
        ),
      );

      final ui.Image markerAsImage =
          await pictureRecorder.endRecording().toImage(size, size);

      final ByteData? byteData = await markerAsImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List markerBytes = byteData!.buffer.asUint8List();

      return BitmapDescriptor.fromBytes(markerBytes);
    } catch (e) {
      debugPrint('Error creating custom marker with transport: $e');
      return BitmapDescriptor.defaultMarker;
    }
  }

  static void clearCache() {
    _markerCache.clear();
  }

  static void clearMarkerFromCache(String imageUrl, {int size = 120}) {
    final cacheKey = '${imageUrl}_$size';
    _markerCache.remove(cacheKey);
  }
}
