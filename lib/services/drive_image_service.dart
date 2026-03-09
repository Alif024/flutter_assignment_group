import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class DriveImageService {
  static Future<String> uploadAssetImage({
    required XFile file,
    required String assetCode,
  }) async {
    if (!_supportsCallableFunctions) {
      throw StateError(
        'Google Drive upload is supported on Android/Web in this app. '
        'Please run on Android emulator/device or web.',
      );
    }

    final bytes = await file.readAsBytes();
    final fileName = _buildFileName(file.name, assetCode);

    final callable = FirebaseFunctions.instanceFor(
      region: 'us-central1',
    ).httpsCallable(
      'uploadAssetImageToDrive',
    );
    HttpsCallableResult<dynamic> response;
    try {
      response = await callable.call({
        'assetCode': assetCode.trim(),
        'fileName': fileName,
        'base64': base64Encode(bytes),
        'mimeType': _guessMimeType(file.name),
      });
    } on FirebaseFunctionsException catch (error) {
      if (error.code == 'not-found') {
        throw StateError(
          'Cloud Function uploadAssetImageToDrive was not found. '
          'Deploy Firebase Functions first.',
        );
      }
      throw StateError('Drive upload failed: ${error.message ?? error.code}');
    } catch (_) {
      throw StateError(
        'Unable to connect to Firebase Functions. '
        'Please full restart the app and verify functions are deployed.',
      );
    }

    final data = response.data;
    if (data is! Map) {
      throw StateError('Invalid upload response.');
    }

    final imageUrl = (data['imageUrl'] as String?)?.trim() ?? '';
    if (imageUrl.isEmpty) {
      throw StateError('Drive image URL is empty.');
    }
    return imageUrl;
  }

  static String _buildFileName(String originalName, String assetCode) {
    final extension = _extractExtension(originalName);
    final normalizedCode = assetCode.trim().isEmpty ? 'asset' : assetCode.trim();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$normalizedCode-$timestamp$extension';
  }

  static String _extractExtension(String fileName) {
    final index = fileName.lastIndexOf('.');
    if (index == -1 || index == fileName.length - 1) {
      return '.jpg';
    }
    return fileName.substring(index);
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

  static bool get _supportsCallableFunctions {
    return kIsWeb || defaultTargetPlatform == TargetPlatform.android;
  }
}
