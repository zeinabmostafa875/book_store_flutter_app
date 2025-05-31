import 'package:flutter/material.dart';
import '../models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  final Function(Book)? onFavoriteToggle;

  const BookDetailScreen({
    super.key,
    required this.book,
    this.onFavoriteToggle,
  });

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList('favorite_books') ?? [];

    setState(() {
      _isFavorite = favoritesJson.any((bookJson) {
        final existingBook = Book.fromJson(json.decode(bookJson));
        return existingBook.id == widget.book.id &&
            existingBook.title == widget.book.title;
      });
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList('favorite_books') ?? [];

    final existingIndex = favoritesJson.indexWhere((bookJson) {
      final existingBook = Book.fromJson(json.decode(bookJson));
      return existingBook.id == widget.book.id &&
          existingBook.title == widget.book.title;
    });

    if (existingIndex != -1) {
    
      favoritesJson.removeAt(existingIndex);
    } else {
   
      favoritesJson.add(json.encode(widget.book.toJson()));
    }

    await prefs.setStringList('favorite_books', favoritesJson);


    setState(() {
      _isFavorite = existingIndex == -1;
    });


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'Added to favorites' : 'Removed from favorites',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: _isFavorite ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );

    widget.onFavoriteToggle?.call(widget.book);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.book.thumbnailUrl != null
                      ? Image.network(
                          widget.book.thumbnailUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(color: Colors.grey[200]),
                  // Gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                widget.book.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.book.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By ${widget.book.primaryAuthor}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.book.description ?? 'No description available',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Future implementation for reading book
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Read Book',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.grey,
                          size: 32,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ],
                  ),
                  // Additional book information section
                  const SizedBox(height: 16),
                  _buildBookDetailsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Book Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildDetailRow('Author', widget.book.primaryAuthor),
        _buildDetailRow(
            'Pages',
            widget.book.pageCount != null
                ? widget.book.pageCount.toString()
                : 'Unknown'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
