import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/library_item.dart';
import '../providers/library_provider.dart';

class DigitalLibraryScreen extends StatefulWidget {
  const DigitalLibraryScreen({super.key});

  @override
  State<DigitalLibraryScreen> createState() => _DigitalLibraryScreenState();
}

class _DigitalLibraryScreenState extends State<DigitalLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Library'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, libraryProvider, child) {
          if (libraryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search books, authors, or topics...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              libraryProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: libraryProvider.setSearchQuery,
                ),
              ),

              // Filters Panel
              if (_showFilters) _buildFiltersPanel(libraryProvider),

              // Results Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${libraryProvider.libraryItems.length} items',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: libraryProvider.sortBy,
                      items: const [
                        DropdownMenuItem(value: 'title', child: Text('Title')),
                        DropdownMenuItem(value: 'author', child: Text('Author')),
                        DropdownMenuItem(value: 'date', child: Text('Date Added')),
                        DropdownMenuItem(value: 'progress', child: Text('Progress')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          libraryProvider.setSortBy(value);
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Library Items List
              Expanded(
                child: libraryProvider.libraryItems.isEmpty
                    ? const Center(
                        child: Text('No items found'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: libraryProvider.libraryItems.length,
                        itemBuilder: (context, index) {
                          final item = libraryProvider.libraryItems[index];
                          return _buildLibraryItemCard(item, libraryProvider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFiltersPanel(LibraryProvider libraryProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Type Filter
          const Text('Type:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: libraryProvider.selectedType == null,
                onSelected: (_) => libraryProvider.setSelectedType(null),
              ),
              FilterChip(
                label: const Text('E-book'),
                selected: libraryProvider.selectedType == LibraryItemType.ebook,
                onSelected: (_) => libraryProvider.setSelectedType(LibraryItemType.ebook),
              ),
              FilterChip(
                label: const Text('Audio'),
                selected: libraryProvider.selectedType == LibraryItemType.audio,
                onSelected: (_) => libraryProvider.setSelectedType(LibraryItemType.audio),
              ),
              FilterChip(
                label: const Text('Document'),
                selected: libraryProvider.selectedType == LibraryItemType.document,
                onSelected: (_) => libraryProvider.setSelectedType(LibraryItemType.document),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Category Filter
          const Text('Categories:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: libraryProvider.categories.map((category) {
              final isSelected = libraryProvider.selectedCategories.contains(category);
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) => libraryProvider.toggleCategory(category),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: libraryProvider.clearFilters,
              child: const Text('Clear All Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryItemCard(LibraryItem item, LibraryProvider libraryProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showItemDetails(context, item, libraryProvider),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  image: item.coverUrl != null
                      ? DecorationImage(
                          image: NetworkImage(item.coverUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: item.coverUrl == null
                    ? Icon(
                        _getTypeIcon(item.type),
                        size: 30,
                        color: Colors.grey[600],
                      )
                    : null,
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            item.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: item.isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: () => libraryProvider.toggleFavorite(item.id),
                        ),
                      ],
                    ),

                    Text(
                      'by ${item.author}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 8),

                    // Progress Bar
                    if (item.progressPercentage > 0) ...[
                      LinearProgressIndicator(
                        value: item.progressPercentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          item.isCompleted ? Colors.green : Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.progressPercentage.toStringAsFixed(1)}% complete',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Categories and Type
                    Row(
                      children: [
                        Icon(_getTypeIcon(item.type), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          item.type.toString().split('.').last,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.categories.join(', '),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(LibraryItemType type) {
    switch (type) {
      case LibraryItemType.ebook:
        return Icons.book;
      case LibraryItemType.audio:
        return Icons.audiotrack;
      case LibraryItemType.document:
        return Icons.description;
    }
  }

  void _showItemDetails(BuildContext context, LibraryItem item, LibraryProvider libraryProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with cover and basic info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                      image: item.coverUrl != null
                          ? DecorationImage(
                              image: NetworkImage(item.coverUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: item.coverUrl == null
                        ? Icon(
                            _getTypeIcon(item.type),
                            size: 40,
                            color: Colors.grey[600],
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'by ${item.author}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(_getTypeIcon(item.type), size: 16),
                            const SizedBox(width: 4),
                            Text(item.type.toString().split('.').last),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                item.isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: item.isFavorite ? Colors.red : Colors.grey,
                              ),
                              onPressed: () {
                                libraryProvider.toggleFavorite(item.id);
                                Navigator.of(context).pop(); // Close and reopen to refresh
                              },
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _openItem(context, item, libraryProvider),
                                child: const Text('Open'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress Section
              const Text(
                'Progress',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: item.progressPercentage / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  item.isCompleted ? Colors.green : Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              Text('${item.progressPercentage.toStringAsFixed(1)}% complete'),

              const SizedBox(height: 16),

              // Description
              const Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(item.description),

              const SizedBox(height: 16),

              // Categories
              const Text(
                'Categories',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: item.categories.map((category) => Chip(label: Text(category))).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openItem(BuildContext context, LibraryItem item, LibraryProvider libraryProvider) {
    // In a real app, this would open the actual content
    // For now, show a simple progress update dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reading: ${item.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current progress: ${item.progressPercentage.toStringAsFixed(1)}%'),
            const SizedBox(height: 16),
            const Text('Update your reading progress:'),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: item.type == LibraryItemType.audio
                    ? 'Minutes listened'
                    : 'Pages read',
              ),
              onSubmitted: (value) {
                final progress = int.tryParse(value) ?? 0;
                libraryProvider.updateProgress(item.id, progress);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Simulate reading progress
              final newProgress = item.currentProgress + 10;
              libraryProvider.updateProgress(item.id, newProgress);
              Navigator.of(context).pop();
            },
            child: const Text('Continue Reading'),
          ),
        ],
      ),
    );
  }
}