import '../models/library_item.dart';

class LibraryService {
  static const String baseUrl = 'https://api.smartclassroom.com'; // Replace with actual API URL

  // Mock data for development
  final List<LibraryItem> _mockLibraryItems = [
    LibraryItem(
      id: '1',
      title: 'Introduction to Flutter',
      author: 'Flutter Team',
      description: 'A comprehensive guide to building apps with Flutter framework.',
      type: LibraryItemType.ebook,
      coverUrl: 'https://example.com/flutter_cover.jpg',
      fileUrl: 'https://example.com/flutter_ebook.pdf',
      categories: ['Programming', 'Mobile Development'],
      totalPages: 350,
      currentProgress: 120,
      isFavorite: true,
      lastAccessed: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    LibraryItem(
      id: '2',
      title: 'Advanced Mathematics',
      author: 'Dr. Sarah Johnson',
      description: 'Deep dive into calculus, algebra, and mathematical concepts.',
      type: LibraryItemType.document,
      coverUrl: 'https://example.com/math_cover.jpg',
      fileUrl: 'https://example.com/math_document.pdf',
      categories: ['Mathematics', 'Education'],
      totalPages: 500,
      currentProgress: 200,
      isFavorite: false,
      lastAccessed: DateTime.now().subtract(const Duration(days: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    LibraryItem(
      id: '3',
      title: 'English Literature Classics',
      author: 'Various Authors',
      description: 'Audio collection of famous English literature works.',
      type: LibraryItemType.audio,
      coverUrl: 'https://example.com/audio_cover.jpg',
      fileUrl: 'https://example.com/audio_playlist.mp3',
      categories: ['Literature', 'Audio Books'],
      durationMinutes: 480,
      currentProgress: 240,
      isFavorite: true,
      lastAccessed: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    LibraryItem(
      id: '4',
      title: 'Physics Fundamentals',
      author: 'Prof. Michael Chen',
      description: 'Basic principles of physics explained with examples.',
      type: LibraryItemType.ebook,
      coverUrl: 'https://example.com/physics_cover.jpg',
      fileUrl: 'https://example.com/physics_ebook.pdf',
      categories: ['Science', 'Physics'],
      totalPages: 280,
      currentProgress: 0,
      isFavorite: false,
      lastAccessed: null,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    LibraryItem(
      id: '5',
      title: 'Chemistry Lab Manual',
      author: 'Dr. Emily Davis',
      description: 'Practical guide for chemistry laboratory experiments.',
      type: LibraryItemType.document,
      coverUrl: 'https://example.com/chem_cover.jpg',
      fileUrl: 'https://example.com/chem_manual.pdf',
      categories: ['Science', 'Chemistry', 'Laboratory'],
      totalPages: 150,
      currentProgress: 75,
      isFavorite: true,
      lastAccessed: DateTime.now().subtract(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    LibraryItem(
      id: '6',
      title: 'History of World War II',
      author: 'Narrator: David Thompson',
      description: 'Comprehensive audio documentary about World War II.',
      type: LibraryItemType.audio,
      coverUrl: 'https://example.com/ww2_cover.jpg',
      fileUrl: 'https://example.com/ww2_audio.mp3',
      categories: ['History', 'Audio Books', 'War'],
      durationMinutes: 720,
      currentProgress: 180,
      isFavorite: false,
      lastAccessed: DateTime.now().subtract(const Duration(days: 7)),
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
    ),
  ];

  Future<List<LibraryItem>> getAllLibraryItems() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock data
    return _mockLibraryItems;

    // Uncomment below for real API call
    /*
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/library/items'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => LibraryItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load library items');
      }
    } catch (e) {
      throw Exception('Error fetching library items: $e');
    }
    */
  }

  Future<List<LibraryItem>> searchLibraryItems(String query, {List<String>? categories, LibraryItemType? type}) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock search functionality
    List<LibraryItem> results = _mockLibraryItems.where((item) {
      final matchesQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query.toLowerCase()) ||
          item.author.toLowerCase().contains(query.toLowerCase()) ||
          item.description.toLowerCase().contains(query.toLowerCase());

      final matchesCategories = categories == null || categories.isEmpty ||
          categories.any((category) => item.categories.contains(category));

      final matchesType = type == null || item.type == type;

      return matchesQuery && matchesCategories && matchesType;
    }).toList();

    return results;

    // Uncomment below for real API call
    /*
    try {
      final queryParams = {
        'q': query,
        if (categories != null && categories.isNotEmpty) 'categories': categories.join(','),
        if (type != null) 'type': type.index.toString(),
      };

      final uri = Uri.parse('$baseUrl/library/search').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => LibraryItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search library items');
      }
    } catch (e) {
      throw Exception('Error searching library items: $e');
    }
    */
  }

  Future<List<String>> getCategories() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 200));

    // Extract unique categories from mock data
    final Set<String> categories = {};
    for (final item in _mockLibraryItems) {
      categories.addAll(item.categories);
    }
    return categories.toList()..sort();

    // Uncomment below for real API call
    /*
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/library/categories'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<String>.from(data);
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
    */
  }

  Future<LibraryItem> updateProgress(String itemId, int progress) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock update progress
    final index = _mockLibraryItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final updatedItem = _mockLibraryItems[index].copyWith(
        currentProgress: progress,
        lastAccessed: DateTime.now(),
      );
      _mockLibraryItems[index] = updatedItem;
      return updatedItem;
    }
    throw Exception('Library item not found');

    // Uncomment below for real API call
    /*
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/library/items/$itemId/progress'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'progress': progress}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LibraryItem.fromJson(data);
      } else {
        throw Exception('Failed to update progress');
      }
    } catch (e) {
      throw Exception('Error updating progress: $e');
    }
    */
  }

  Future<LibraryItem> toggleFavorite(String itemId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock toggle favorite
    final index = _mockLibraryItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final currentItem = _mockLibraryItems[index];
      final updatedItem = currentItem.copyWith(
        isFavorite: !currentItem.isFavorite,
      );
      _mockLibraryItems[index] = updatedItem;
      return updatedItem;
    }
    throw Exception('Library item not found');

    // Uncomment below for real API call
    /*
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/library/items/$itemId/favorite'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'isFavorite': !currentItem.isFavorite}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LibraryItem.fromJson(data);
      } else {
        throw Exception('Failed to toggle favorite');
      }
    } catch (e) {
      throw Exception('Error toggling favorite: $e');
    }
    */
  }
}