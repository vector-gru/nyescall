import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../../core/constants/api_keys.dart';
import '../../../core/constants/env_config.dart';
import '../../../core/errors/app_exception.dart';

/// Handles all image/audio uploads using the Cloudinary free tier.
///
/// Free tier includes 25 GB storage + 25 GB monthly bandwidth — more than
/// enough for profile photos, org logos, and voice samples.
///
/// Uses *unsigned* uploads (no secret needed on the client) via a
/// pre-configured upload preset.  The upload preset restricts allowed
/// file types and max size on the Cloudinary side.
class CloudinaryService {
  CloudinaryService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: EnvConfig.apiConnectTimeout,
              receiveTimeout: EnvConfig.apiReceiveTimeout,
            ));

  final Dio _dio;

  // ── Upload ────────────────────────────────────────────────────────────────

  /// Uploads any file (image or audio) and returns the public URL.
  ///
  /// [folder]  — Cloudinary folder, e.g. 'profiles', 'logos', 'voices'
  /// [publicId] — optional explicit name; Cloudinary auto-generates one if null
  Future<CloudinaryUploadResult> uploadFile({
    required String localPath,
    required String folder,
    String? publicId,
  }) async {
    final cloudName = ApiKeys.cloudinaryCloudName;
    final preset = ApiKeys.cloudinaryUploadPreset;

    if (cloudName.startsWith('REPLACE') || preset.startsWith('REPLACE')) {
      throw const DataException(
        'Cloudinary is not configured. '
        'Set cloudinaryCloudName and cloudinaryUploadPreset in api_keys.dart.',
      );
    }

    final mimeType = lookupMimeType(localPath) ?? 'application/octet-stream';
    final parts = mimeType.split('/');

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          localPath,
          contentType: MediaType(parts[0], parts[1]),
        ),
        'upload_preset': preset,
        'folder': folder,
        if (publicId != null) 'public_id': publicId,
      });

      final response = await _dio.post(
        EnvConfig.cloudinaryUploadUrl(cloudName),
        data: formData,
      );

      final data = response.data as Map<String, dynamic>;
      return CloudinaryUploadResult(
        publicId: data['public_id'] as String,
        secureUrl: data['secure_url'] as String,
        format: data['format'] as String? ?? '',
        resourceType: data['resource_type'] as String? ?? 'image',
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['error']?['message'] as String?;
      throw DataException(msg ?? 'Cloudinary upload failed: ${e.message}');
    }
  }

  // ── Convenience wrappers ──────────────────────────────────────────────────

  Future<CloudinaryUploadResult> uploadProfilePhoto({
    required String uid,
    required String localPath,
  }) =>
      uploadFile(
        localPath: localPath,
        folder: 'profiles',
        publicId: 'user_$uid',
      );

  Future<CloudinaryUploadResult> uploadOrgLogo({
    required String orgId,
    required String localPath,
  }) =>
      uploadFile(
        localPath: localPath,
        folder: 'organizations',
        publicId: 'org_$orgId',
      );

  Future<CloudinaryUploadResult> uploadStaffPhoto({
    required String staffCode,
    required String localPath,
  }) =>
      uploadFile(
        localPath: localPath,
        folder: 'staff',
        publicId: 'staff_${staffCode.replaceAll('-', '_')}',
      );

  Future<CloudinaryUploadResult> uploadVoiceSample({
    required String uid,
    required String voiceName,
    required String localPath,
  }) =>
      uploadFile(
        localPath: localPath,
        folder: 'voices',
        publicId:
            'voice_${uid}_${voiceName.toLowerCase().replaceAll(' ', '_')}',
      );

  // ── URL helpers ───────────────────────────────────────────────────────────

  /// Returns a resized, auto-optimised URL — no additional storage cost.
  String transformedUrl(
    String publicId, {
    int width = 200,
    int height = 200,
    String crop = 'fill',
  }) =>
      EnvConfig.cloudinaryTransform(
        ApiKeys.cloudinaryCloudName,
        publicId,
        width: width,
        height: height,
        crop: crop,
      );
}

// ── Result ────────────────────────────────────────────────────────────────

class CloudinaryUploadResult {
  const CloudinaryUploadResult({
    required this.publicId,
    required this.secureUrl,
    required this.format,
    required this.resourceType,
  });

  final String publicId;
  final String secureUrl;
  final String format;
  final String resourceType;
}
