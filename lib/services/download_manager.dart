import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class DownloadManager {
  final Dio _dio = Dio();

  Future<String> _getDownloadDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final downloadDir = Directory(path.join(directory.path, 'downloads'));
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir.path;
  }

  Future<String?> downloadMaterial(
    String url,
    String filename, {
    Function(double)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final downloadDir = await _getDownloadDirectory();
      final filePath = path.join(downloadDir, filename);

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
        cancelToken: cancelToken,
      );

      return filePath;
    } catch (e) {
      print('Download failed: $e');
      return null;
    }
  }

  Future<bool> isMaterialDownloaded(String filename) async {
    final downloadDir = await _getDownloadDirectory();
    final filePath = path.join(downloadDir, filename);
    return File(filePath).exists();
  }

  Future<String?> getLocalPath(String filename) async {
    final downloadDir = await _getDownloadDirectory();
    final filePath = path.join(downloadDir, filename);
    if (await File(filePath).exists()) {
      return filePath;
    }
    return null;
  }

  Future<void> deleteDownloadedMaterial(String filename) async {
    final downloadDir = await _getDownloadDirectory();
    final filePath = path.join(downloadDir, filename);
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}