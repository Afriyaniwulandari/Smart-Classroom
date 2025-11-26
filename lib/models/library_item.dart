enum LibraryItemType {
  ebook,
  audio,
  document,
}

class LibraryItem {
  final String id;
  final String title;
  final String author;
  final String description;
  final LibraryItemType type;
  final String? coverUrl;
  final String? fileUrl;
  final List<String> categories;
  final int totalPages; // for ebooks and documents
  final int durationMinutes; // for audio
  final int currentProgress; // pages read or minutes listened
  final bool isFavorite;
  final DateTime? lastAccessed;
  final DateTime createdAt;

  LibraryItem({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.type,
    this.coverUrl,
    this.fileUrl,
    required this.categories,
    this.totalPages = 0,
    this.durationMinutes = 0,
    this.currentProgress = 0,
    this.isFavorite = false,
    this.lastAccessed,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get progressPercentage {
    if (type == LibraryItemType.audio) {
      return durationMinutes > 0 ? (currentProgress / durationMinutes) * 100 : 0;
    } else {
      return totalPages > 0 ? (currentProgress / totalPages) * 100 : 0;
    }
  }

  bool get isCompleted {
    return progressPercentage >= 100;
  }

  factory LibraryItem.fromJson(Map<String, dynamic> json) {
    return LibraryItem(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      description: json['description'],
      type: LibraryItemType.values[json['type']],
      coverUrl: json['coverUrl'],
      fileUrl: json['fileUrl'],
      categories: List<String>.from(json['categories'] ?? []),
      totalPages: json['totalPages'] ?? 0,
      durationMinutes: json['durationMinutes'] ?? 0,
      currentProgress: json['currentProgress'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      lastAccessed: json['lastAccessed'] != null ? DateTime.parse(json['lastAccessed']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'type': type.index,
      'coverUrl': coverUrl,
      'fileUrl': fileUrl,
      'categories': categories,
      'totalPages': totalPages,
      'durationMinutes': durationMinutes,
      'currentProgress': currentProgress,
      'isFavorite': isFavorite,
      'lastAccessed': lastAccessed?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  LibraryItem copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    LibraryItemType? type,
    String? coverUrl,
    String? fileUrl,
    List<String>? categories,
    int? totalPages,
    int? durationMinutes,
    int? currentProgress,
    bool? isFavorite,
    DateTime? lastAccessed,
    DateTime? createdAt,
  }) {
    return LibraryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      type: type ?? this.type,
      coverUrl: coverUrl ?? this.coverUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      categories: categories ?? this.categories,
      totalPages: totalPages ?? this.totalPages,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      currentProgress: currentProgress ?? this.currentProgress,
      isFavorite: isFavorite ?? this.isFavorite,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}