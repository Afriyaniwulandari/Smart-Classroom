class Bookmark {
  final String id;
  final String lessonId;
  final String userId;
  final String lessonTitle;
  final String lessonDescription;
  final DateTime bookmarkedAt;
  bool isDownloaded;
  String? localPath;

  Bookmark({
    required this.id,
    required this.lessonId,
    required this.userId,
    required this.lessonTitle,
    required this.lessonDescription,
    required this.bookmarkedAt,
    this.isDownloaded = false,
    this.localPath,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      lessonId: json['lessonId'],
      userId: json['userId'],
      lessonTitle: json['lessonTitle'],
      lessonDescription: json['lessonDescription'],
      bookmarkedAt: DateTime.parse(json['bookmarkedAt']),
      isDownloaded: json['isDownloaded'] ?? false,
      localPath: json['localPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'userId': userId,
      'lessonTitle': lessonTitle,
      'lessonDescription': lessonDescription,
      'bookmarkedAt': bookmarkedAt.toIso8601String(),
      'isDownloaded': isDownloaded,
      'localPath': localPath,
    };
  }
}