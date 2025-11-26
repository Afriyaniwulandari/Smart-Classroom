import 'package:flutter/material.dart';
import '../models/library_item.dart';
import '../services/library_service.dart';

class LibraryProvider with ChangeNotifier {
  final LibraryService _libraryService = LibraryService();

  List<LibraryItem> _libraryItems = [];
  List<LibraryItem> _filteredItems = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String _searchQuery = '';
  List<String> _selectedCategories = [];
  LibraryItemType? _selectedType;
  String _sortBy = 'title'; // title, author, date, progress

  // Getters
  List<LibraryItem> get libraryItems => _filteredItems;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  List<String> get selectedCategories => _selectedCategories;
  LibraryItemType? get selectedType => _selectedType;
  String get sortBy => _sortBy;

  List<LibraryItem> get favoriteItems => _libraryItems.where((item) => item.isFavorite).toList();
  List<LibraryItem> get recentItems => _libraryItems
      .where((item) => item.lastAccessed != null)
      .toList()
      ..sort((a, b) => b.lastAccessed!.compareTo(a.lastAccessed!));

  Future<void> loadLibraryItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _libraryItems = await _libraryService.getAllLibraryItems();
      _applyFiltersAndSort();
    } catch (e) {
      // Handle error - in a real app, you'd show an error message
      print('Error loading library items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _libraryService.getCategories();
      notifyListeners();
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
  }

  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    _applyFiltersAndSort();
  }

  void setSelectedType(LibraryItemType? type) {
    _selectedType = type;
    _applyFiltersAndSort();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    _applyFiltersAndSort();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategories.clear();
    _selectedType = null;
    _applyFiltersAndSort();
  }

  Future<void> updateProgress(String itemId, int progress) async {
    try {
      final updatedItem = await _libraryService.updateProgress(itemId, progress);

      // Update local list
      final index = _libraryItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _libraryItems[index] = updatedItem;
        _applyFiltersAndSort();
      }
    } catch (e) {
      print('Error updating progress: $e');
      // In a real app, show error to user
    }
  }

  Future<void> toggleFavorite(String itemId) async {
    try {
      final updatedItem = await _libraryService.toggleFavorite(itemId);

      // Update local list
      final index = _libraryItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _libraryItems[index] = updatedItem;
        _applyFiltersAndSort();
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      // In a real app, show error to user
    }
  }

  void _applyFiltersAndSort() {
    List<LibraryItem> filtered = List.from(_libraryItems);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               item.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply category filter
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered.where((item) {
        return _selectedCategories.any((category) => item.categories.contains(category));
      }).toList();
    }

    // Apply type filter
    if (_selectedType != null) {
      filtered = filtered.where((item) => item.type == _selectedType).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'author':
          return a.author.compareTo(b.author);
        case 'date':
          return b.createdAt.compareTo(a.createdAt);
        case 'progress':
          return b.progressPercentage.compareTo(a.progressPercentage);
        case 'title':
        default:
          return a.title.compareTo(b.title);
      }
    });

    _filteredItems = filtered;
    notifyListeners();
  }

  LibraryItem? getLibraryItemById(String id) {
    return _libraryItems.firstWhere((item) => item.id == id);
  }

  // Initialize provider
  Future<void> initialize() async {
    await Future.wait([
      loadLibraryItems(),
      loadCategories(),
    ]);
  }
}