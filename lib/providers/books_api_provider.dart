import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BooksApiProvider {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes?q=flutter';
  static const int _defaultMaxResults = 40;

  Future<List<Book>> fetchBooks({
    required String query,
    int startIndex = 0,
    int maxResults = 20,
  }) async {
    try {
      final encodedQuery = Uri.encodeQueryComponent(query);
      final url =
          '$_baseUrl?q=$encodedQuery&startIndex=$startIndex&maxResults=$maxResults';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['items'] != null) {
          return (data['items'] as List)
              .map((bookJson) => Book.fromJson(bookJson))
              .where(
                  (book) => book.title.isNotEmpty && book.thumbnailUrl != null)
              .toList();
        } else {
          debugPrint('No books found for query: $query');
          return [];
        }
      } else {
        debugPrint(
            'Failed to fetch books. Status code: ${response.statusCode}');
        throw Exception('Failed to load books');
      }
    } catch (e) {
      debugPrint('Error fetching books: $e');
      rethrow;
    }
  }

  Future<Book?> fetchBookDetails(String bookId) async {
    try {
      final url = '$_baseUrl/$bookId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Book.fromJson(data);
      } else {
        debugPrint(
            'Failed to fetch book details. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching book details: $e');
      return null;
    }
  }

  Future<List<Book>> searchBooks(String query) async {
    return fetchBooks(query: query, startIndex: 0, maxResults: 10);
  }
}
