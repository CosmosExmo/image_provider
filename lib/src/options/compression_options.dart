part of '../../image_provider.dart';

class CompressionOptions {
  final int minWidth;
  final int minHeight;
  final int quality;
  final int rotate;
  final int inSampleSize;
  final bool autoCorrectionAngle;
  final CompressFormat format;
  final bool keepExif;

  const CompressionOptions({
    this.minWidth = 800,
    this.minHeight = 600,
    this.quality = 80,
    this.rotate = 0,
    this.inSampleSize = 1,
    this.autoCorrectionAngle = true,
    this.format = CompressFormat.jpeg,
    this.keepExif = false,
  });
}