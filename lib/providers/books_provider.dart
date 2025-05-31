import 'package:flutter/foundation.dart';
import '../models/book.dart';
import 'books_api_provider.dart';

class BooksProvider with ChangeNotifier {
  final BooksApiProvider _apiProvider = BooksApiProvider();

  final List<Book> _books = [];
  final List<Book> _favoriteBooks = [];
  bool _isLoading = false;
  String _error = '';
  int _startIndex = 0;

  List<Book> get books => _books;
  List<Book> get favoriteBooks => _favoriteBooks;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchBooks(
      {String query = 'flutter', bool reset = false}) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = '';

      if (reset) {
        _books.clear();
        _startIndex = 0;
      }

      final newBooks = await _apiProvider.fetchBooks(
        query: query,
        startIndex: _startIndex,
      );

      _books.addAll(newBooks);
      _startIndex += newBooks.length;
      _isLoading = false;

      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void toggleFavorite(Book book) {
    if (_favoriteBooks.contains(book)) {
      _favoriteBooks.remove(book);
    } else {
      _favoriteBooks.add(book);
    }
    notifyListeners();
  }

  bool isFavorite(Book book) {
    return _favoriteBooks.contains(book);
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
