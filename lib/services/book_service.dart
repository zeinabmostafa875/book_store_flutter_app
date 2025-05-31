import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  static const String _apiBaseUrl =
      'https://www.googleapis.com/books/v1/volumes';


  static Future<List<Book>> fetchBooks() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl?q=flutter'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> booksData = data['items'] ?? [];

        final List<Book> books = booksData.map((bookJson) {
          final volumeInfo = bookJson['volumeInfo'] ?? {};
          final imageLinks = volumeInfo['imageLinks'] ?? {};

          return Book(
            id: bookJson['id'] ?? '',
            title: volumeInfo['title'] ?? 'Unknown Title',
            primaryAuthor: (volumeInfo['authors'] is List &&
                    volumeInfo['authors'].isNotEmpty)
                ? volumeInfo['authors'][0]
                : 'Unknown Author',
            description: volumeInfo['description'] ?? '',
            thumbnailUrl:
                imageLinks['thumbnail'] ?? 'https://via.placeholder.com/150',
            pageCount: volumeInfo['pageCount'] ?? 0,
            rating: (volumeInfo['averageRating'] as num?)?.toDouble(),
          );
        }).toList();

        return books;
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      return [
        Book(
          id: '1',
          title: 'Sample Book',
          primaryAuthor: 'Unknown Author',
          thumbnailUrl: 'https://via.placeholder.com/150',
        )
      ];
    }
  }

  // Search books
  static Future<List<Book>> searchBooks(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl?q=$query'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> booksData = data['items'] ?? [];

        // Convert Google Books API response to our Book model
        final List<Book> books = booksData.map((bookJson) {
          final volumeInfo = bookJson['volumeInfo'] ?? {};
          final imageLinks = volumeInfo['imageLinks'] ?? {};

          return Book(
            id: bookJson['id'] ?? '',
            title: volumeInfo['title'] ?? 'Unknown Title',
            primaryAuthor: (volumeInfo['authors'] is List &&
                    volumeInfo['authors'].isNotEmpty)
                ? volumeInfo['authors'][0]
                : 'Unknown Author',
            description: volumeInfo['description'] ?? '',
            thumbnailUrl:
                imageLinks['thumbnail'] ?? 'https://via.placeholder.com/150',
            pageCount: volumeInfo['pageCount'] ?? 0,
            rating: (volumeInfo['averageRating'] as num?)?.toDouble(),
          );
        }).toList();

        return books;
      } else {
        throw Exception('Failed to search books');
      }
    } catch (e) {
      return [];
    }
  }

  // Get book by ID
  static Future<Book> getBookById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/$id'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> bookData = json.decode(response.body);
        final volumeInfo = bookData['volumeInfo'] ?? {};
        final imageLinks = volumeInfo['imageLinks'] ?? {};

        return Book(
          id: bookData['id'] ?? '',
          title: volumeInfo['title'] ?? 'Unknown Title',
          primaryAuthor: (volumeInfo['authors'] is List &&
                  volumeInfo['authors'].isNotEmpty)
              ? volumeInfo['authors'][0]
              : 'Unknown Author',
          description: volumeInfo['description'] ?? '',
          thumbnailUrl:
              imageLinks['thumbnail'] ?? 'https://via.placeholder.com/150',
          pageCount: volumeInfo['pageCount'] ?? 0,
          rating: (volumeInfo['averageRating'] as num?)?.toDouble(),
        );
      } else {
        throw Exception('Failed to get book');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get books by category
  static Future<List<Book>> getBooksByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl?q=subject:$category'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> booksData = data['items'] ?? [];

        return booksData.map((bookJson) {
          final volumeInfo = bookJson['volumeInfo'] ?? {};
          final imageLinks = volumeInfo['imageLinks'] ?? {};

          return Book(
            id: bookJson['id'] ?? '',
            title: volumeInfo['title'] ?? 'Unknown Title',
            primaryAuthor: (volumeInfo['authors'] is List &&
                    volumeInfo['authors'].isNotEmpty)
                ? volumeInfo['authors'][0]
                : 'Unknown Author',
            description: volumeInfo['description'] ?? '',
            thumbnailUrl:
                imageLinks['thumbnail'] ?? 'https://via.placeholder.com/150',
            pageCount: volumeInfo['pageCount'] ?? 0,
            rating: (volumeInfo['averageRating'] as num?)?.toDouble(),
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
