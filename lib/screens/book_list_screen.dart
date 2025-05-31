import 'package:flutter/material.dart';
import '../models/book.dart';
import '../screens/book_detail_screen.dart';
import '../screens/favorites_screen.dart';
import '../services/book_service.dart';
import '../services/favorites_service.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Book> _books = [];
  List<Book> _favoriteBooks = [];
  bool _isLoading = true;
  String _currentQuery = 'books';

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _fetchFavoriteBooks();
  }

  Future<void> _fetchBooks() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final books = await BookService.fetchBooks();

      debugPrint('Fetched books in BookListScreen: ${books.length}');
      books.forEach((book) {
        debugPrint(
            'Book: ${book.title}, Author: ${book.primaryAuthor}, Thumbnail: ${book.thumbnailUrl}');
      });

      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch books: $e')),
      );
    }
  }

  Future<void> _fetchFavoriteBooks() async {
    try {
      final favoriteBooks = await FavoritesService.getFavoriteBooks();

      setState(() {
        _favoriteBooks = favoriteBooks;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch favorites: $e')),
      );
    }
  }

  void _searchBooks() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _currentQuery = query;
        _isLoading = true;
      });

      BookService.searchBooks(query).then((searchedBooks) {
        setState(() {
          _books = searchedBooks;
          _isLoading = false;
        });
      }).catchError((e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      });
    }
  }

  Future<void> _toggleFavorite(Book book) async {
    try {
      final isFavorite = await FavoritesService.isBookFavorite(book);

      if (isFavorite) {
        await FavoritesService.removeFromFavorites(book);
      } else {
        await FavoritesService.addToFavorites(book);
      }

      // Refresh favorite books
      await _fetchFavoriteBooks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle favorite: $e')),
      );
    }
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

  void _navigateToFavoritesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavoritesScreen(),
      ),
    ).then((_) {
   
      _fetchFavoriteBooks();
    });
  }

  bool _isBookFavorite(Book book) {
    return _favoriteBooks
        .any((favBook) => favBook.id == book.id && favBook.title == book.title);
  }

  Widget _buildBookSection(
      {required String title,
      required List<Book> books,
      bool isHorizontal = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: isHorizontal ? 350 : null,
          child: isHorizontal
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return _buildBookCard(book, isHorizontal: true);
                  },
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return _buildBookCard(book, isHorizontal: false);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBookCard(Book book, {bool isHorizontal = true}) {
    return GestureDetector(
      onTap: () => _navigateToBookDetails(book),
      child: Container(
        width: isHorizontal ? 200 : null,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: isHorizontal ? 280 : 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
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
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      _toggleFavorite(book);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        _isBookFavorite(book)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            _isBookFavorite(book) ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              book.primaryAuthor,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueReadingSection() {
    if (_books.isEmpty) return const SizedBox.shrink();

    final book = _books.first;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Continue Reading',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _navigateToBookDetails(book),
            child: Container(
              height: 120,
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
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            book.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
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
                          const Text(
                            'Chapter 2 - New Hope',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: IconButton(
                      icon: const Icon(Icons.play_circle_outline,
                          color: Colors.blue),
                      onPressed: () => _navigateToBookDetails(book),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchBooks,
                child: CustomScrollView(
                  slivers: [
                    // App Bar
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      title: const Text(
                        'Book Store',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 28,
                          ),
                          onPressed: _navigateToFavoritesScreen,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.black,
                            size: 28,
                          ),
                          onPressed: () {
                            AuthService.logout();
                            Navigator.of(context)
                                .pushReplacementNamed('/login');
                          },
                        ),
                      ],
                      backgroundColor: Colors.white,
                      elevation: 0,
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(60),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search books...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                            onSubmitted: (_) => _searchBooks(),
                          ),
                        ),
                      ),
                    ),

                    // My Books Section
                    SliverToBoxAdapter(
                      child: _buildBookSection(
                        title: 'My Books',
                        books: _books.take(15).toList(),
                      ),
                    ),

                    // Continue Reading Section
                    SliverToBoxAdapter(
                      child: _buildContinueReadingSection(),
                    ),

                    // New Arrival Section
                    SliverToBoxAdapter(
                      child: _buildBookSection(
                        title: 'New Arrival',
                        books: _books.take(15).toList(),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
