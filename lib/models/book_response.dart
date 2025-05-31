import 'package:flutter/foundation.dart';
import 'book.dart';

@immutable
class BookResponse {
  final List<Book> books;
  final int totalItems;

  const BookResponse({
    required this.books,
    required this.totalItems,
  });

  factory BookResponse.fromJson(Map<String, dynamic> json) {

    final items = json['items'] ?? [];
    final totalItems = _safeInt(json, 'totalItems');

    final parsedBooks = _safeParsedBooks(items);

    return BookResponse(
      books: parsedBooks,
      totalItems: totalItems,
    );
  }


  static int _safeInt(
    Map<String, dynamic> map,
    String key, {
    int defaultValue = 0,
  }) {
    final value = map[key];
    return value is int ? value : defaultValue;
  }


  static List<Book> _safeParsedBooks(List<dynamic> items) {
    final parsedBooks = <Book>[];

    for (var item in items) {
      try {
        if (item is Map<String, dynamic>) {
          final book = Book.fromJson(item);
          parsedBooks.add(book);
        }
      } catch (e) {

        debugPrint('Error parsing book: $e');
      }
    }

    return parsedBooks;
  }

  BookResponse copyWith({
    List<Book>? books,
    int? totalItems,
  }) {
    return BookResponse(
      books: books ?? this.books,
      totalItems: totalItems ?? this.totalItems,
    );
  }
}
