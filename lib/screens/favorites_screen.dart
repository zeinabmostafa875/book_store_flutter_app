import 'package:flutter/material.dart';
import '../models/book.dart';
import '../screens/book_detail_screen.dart';
import '../services/favorites_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isEditing = false;
  Set<Book> _selectedBooks = {};
  List<Book> _favoriteBooks = [];
  final ValueNotifier<List<Book>> _favoritesNotifier =
      ValueNotifier<List<Book>>([]);

  @override
  void initState() {
    super.initState();
    _fetchFavoriteBooks();
  }

  Future<void> _fetchFavoriteBooks() async {
    try {
      final favoriteBooks = await FavoritesService.getFavoriteBooks();

      setState(() {
        _favoriteBooks = favoriteBooks;
        _favoritesNotifier.value = favoriteBooks;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch favorites: $e')),
      );
    }
  }

  void _toggleBookSelection(Book book) {
    setState(() {
      if (_selectedBooks.contains(book)) {
        _selectedBooks.remove(book);
      } else {
        _selectedBooks.add(book);
      }
    });
  }

  Future<void> _removeSelectedFavorites() async {
    for (var book in _selectedBooks) {
      await FavoritesService.removeFromFavorites(book);
    }

    setState(() {
      _selectedBooks.clear();
      _isEditing = false;
    });

    await _fetchFavoriteBooks();
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites'),
        content:
            const Text('Are you sure you want to remove all favorite books?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FavoritesService.clearAllFavorites();

              Navigator.of(context).pop();
              await _fetchFavoriteBooks();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _navigateToBookDetails(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailScreen(
          book: book,
          onFavoriteToggle: (updatedBook) {
            _fetchFavoriteBooks();
          },
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return ValueListenableBuilder<List<Book>>(
      valueListenable: _favoritesNotifier,
      builder: (context, favoriteBooks, child) {
        if (favoriteBooks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 100,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 20),
                const Text(
                  'No Favorite Books Yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/book_list');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Explore Books',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favoriteBooks.length,
          itemBuilder: (context, index) {
            final book = favoriteBooks[index];
            final isSelected = _selectedBooks.contains(book);

            return GestureDetector(
              onTap: _isEditing
                  ? () => _toggleBookSelection(book)
                  : () => _navigateToBookDetails(book),
              onLongPress: () {
                setState(() {
                  _isEditing = true;
                  _selectedBooks.add(book);
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: _isEditing && isSelected
                      ? Border.all(color: Colors.blue, width: 2)
                      : null,
                ),
                child: Row(
                  children: [
                    // Book Cover
                    Container(
                      width: 100,
                      height: 150,
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: book.thumbnailUrl != null
                            ? DecorationImage(
                                image: NetworkImage(book.thumbnailUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.grey[200],
                      ),
                      child: book.thumbnailUrl == null
                          ? const Center(child: Text('No Image'))
                          : null,
                    ),
                    // Book Details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book.primaryAuthor,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    // Favorite Icon
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: _isEditing && isSelected ? 30 : 24,
                      ),
                      onPressed: () => _toggleFavorite(book),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _toggleFavorite(Book book) async {
    await FavoritesService.removeFromFavorites(book);
    await _fetchFavoriteBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isEditing ? '${_selectedBooks.length} Selected' : 'Favorite Books',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: _isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _removeSelectedFavorites,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _selectedBooks.clear();
                    });
                  },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Colors.red),
                  onPressed: _showClearAllDialog,
                ),
              ],
      ),
      body: _buildFavoritesList(),
    );
  }
}
