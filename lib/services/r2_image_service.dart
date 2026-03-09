import 'package:aws_s3_api/s3-2006-03-01.dart' as s3;
import 'package:shared_aws_api/shared.dart';
import 'package:flutter_assignment_group/config/r2_config.dart';
import 'package:image_picker/image_picker.dart';

class R2ImageService {
  static Future<String> uploadAssetImage({
    required XFile file,
    required String assetCode,
  }) async {
    _assertConfig();

    final bytes = await file.readAsBytes();
    final contentType = _guessMimeType(file.name);
    final objectKey = _buildObjectKey(file.name, assetCode);

    final client = s3.S3(
      region: 'auto',
      endpointUrl: 'https://${R2Config.accountId}.r2.cloudflarestorage.com',
      credentials: AwsClientCredentials(
        accessKey: R2Config.accessKeyId,
        secretKey: R2Config.secretAccessKey,
      ),
    );

    try {
      await client.putObject(
        bucket: R2Config.bucketName,
        key: objectKey,
        body: bytes,
        contentType: contentType,
      );
    } finally {
      client.close();
    }

    return _publicUrlFor(objectKey);
  }

  static void _assertConfig() {
    if (R2Config.accountId.isEmpty ||
        R2Config.bucketName.isEmpty ||
        R2Config.accessKeyId.isEmpty ||
        R2Config.secretAccessKey.isEmpty) {
      throw StateError(
        'R2 config is missing. Provide R2_ACCOUNT_ID, R2_BUCKET_NAME, '
        'R2_ACCESS_KEY_ID and R2_SECRET_ACCESS_KEY via --dart-define.',
      );
    }
  }

  static String _buildObjectKey(String originalName, String assetCode) {
    final extension = _extractExtension(originalName);
    final code = assetCode.trim().isEmpty ? 'asset' : assetCode.trim();
    final now = DateTime.now().millisecondsSinceEpoch;
    final prefix = R2Config.objectPrefix.trim();
    if (prefix.isEmpty) {
      return '$code/$now$extension';
    }
    return '$prefix/$code/$now$extension';
  }

  static String _extractExtension(String fileName) {
    final index = fileName.lastIndexOf('.');
    if (index == -1 || index == fileName.length - 1) {
      return '.jpg';
    }
    return fileName.substring(index).toLowerCase();
  }

  static String _guessMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }

  static String _publicUrlFor(String objectKey) {
    final base = R2Config.publicBaseUrl.trim();
    if (base.isEmpty) {
      throw StateError(
        'R2_PUBLIC_BASE_URL is required to build image URL '
        '(for example https://pub-xxxx.r2.dev).',
      );
    }
    return '${base.replaceAll(RegExp(r'/$'), '')}/$objectKey';
  }
}
