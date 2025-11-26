import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark.dart';
import '../models/lesson.dart';
import '../services/download_manager.dart';

class BookmarkProvider with ChangeNotifier {
  List<Bookmark> _bookmarks = [];
  final DownloadManager _downloadManager = DownloadManager();

  List<Bookmark> get bookmarks => _bookmarks;

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getStringList('bookmarks') ?? [];
    _bookmarks = bookmarksJson
        .map((json) => Bookmark.fromJson(jsonDecode(json)))
        .toList();
    notifyListeners();
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = _bookmarks
        .map((bookmark) => jsonEncode(bookmark.toJson()))
        .toList();
    await prefs.setStringList('bookmarks', bookmarksJson);
  }

  Future<void> addBookmark(Lesson lesson, String userId) async {
    final existingBookmark = _bookmarks.firstWhere(
      (b) => b.lessonId == lesson.id && b.userId == userId,
      orElse: () => Bookmark(
        id: '',
        lessonId: lesson.id,
        userId: userId,
        lessonTitle: lesson.title,
        lessonDescription: lesson.description,
        bookmarkedAt: DateTime.now(),
      ),
    );

    if (existingBookmark.id.isEmpty) {
      final bookmark = Bookmark(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        lessonId: lesson.id,
        userId: userId,
        lessonTitle: lesson.title,
        lessonDescription: lesson.description,
        bookmarkedAt: DateTime.now(),
      );
      _bookmarks.add(bookmark);
      await _saveBookmarks();
      notifyListeners();
    }
  }

  Future<void> removeBookmark(String lessonId, String userId) async {
    _bookmarks.removeWhere(
      (b) => b.lessonId == lessonId && b.userId == userId,
    );
    await _saveBookmarks();
    notifyListeners();
  }

  bool isBookmarked(String lessonId, String userId) {
    return _bookmarks.any(
      (b) => b.lessonId == lessonId && b.userId == userId,
    );
  }

  Future<String?> downloadMaterial(
    String url,
    String filename, {
    Function(double)? onProgress,
  }) async {
    final localPath = await _downloadManager.downloadMaterial(
      url,
      filename,
      onProgress: onProgress,
    );

    if (localPath != null) {
      // Update bookmark with download status if applicable
      final bookmark = _bookmarks.firstWhere(
        (b) => b.lessonId == filename.split('_')[0], // Assuming filename starts with lessonId
        orElse: () => Bookmark(id: '', lessonId: '', userId: '', lessonTitle: '', lessonDescription: '', bookmarkedAt: DateTime.now()),
      );
      if (bookmark.id.isNotEmpty) {
        bookmark.isDownloaded = true;
        bookmark.localPath = localPath;
        await _saveBookmarks();
        notifyListeners();
      }
    }

    return localPath;
  }

  Future<bool> isMaterialDownloaded(String filename) async {
    return await _downloadManager.isMaterialDownloaded(filename);
  }

  Future<String?> getLocalPath(String filename) async {
    return await _downloadManager.getLocalPath(filename);
  }
}