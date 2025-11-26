import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../providers/auth_provider.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    final bookmarkProvider = Provider.of<BookmarkProvider>(context, listen: false);
    bookmarkProvider.loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view bookmarks')),
      );
    }

    final userBookmarks = bookmarkProvider.bookmarks
        .where((b) => b.userId == user.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked Lessons'),
      ),
      body: userBookmarks.isEmpty
          ? const Center(
              child: Text('No bookmarked lessons'),
            )
          : ListView.builder(
              itemCount: userBookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = userBookmarks[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(bookmark.lessonTitle),
                    subtitle: Text(bookmark.lessonDescription),
                    trailing: IconButton(
                      icon: const Icon(Icons.bookmark),
                      onPressed: () {
                        bookmarkProvider.removeBookmark(bookmark.lessonId, user.id);
                      },
                    ),
                    onTap: () {
                      // For now, since we don't have the full lesson, perhaps navigate to a placeholder or try to load
                      // In a real app, might need to fetch the lesson or store more data
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Offline lesson access not implemented yet')),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}