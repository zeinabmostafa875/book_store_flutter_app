import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_books';


  static Future<List<Book>> getFavoriteBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      return favoritesJson.map((bookJson) {
        return Book.fromJson(json.decode(bookJson));
      }).toList();
    } catch (e) {
      print('Error fetching favorite books: $e');
      return [];
    }
  }


  static Future<bool> addToFavorites(Book book) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];


      final existingIndex = favoritesJson.indexWhere((bookJson) {
        final existingBook = Book.fromJson(json.decode(bookJson));
        return existingBook.id == book.id && existingBook.title == book.title;
      });

      if (existingIndex == -1) {
   
        favoritesJson.add(json.encode(book.toJson()));
        await prefs.setStringList(_favoritesKey, favoritesJson);
        return true;
      }

      return false;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }


  static Future<bool> removeFromFavorites(Book book) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      final updatedFavorites = favoritesJson.where((bookJson) {
        final existingBook = Book.fromJson(json.decode(bookJson));
        return !(existingBook.id == book.id &&
            existingBook.title == book.title);
      }).toList();

      await prefs.setStringList(_favoritesKey, updatedFavorites);
      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }


  static Future<bool> isBookFavorite(Book book) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      return favoritesJson.any((bookJson) {
        final existingBook = Book.fromJson(json.decode(bookJson));
        return existingBook.id == book.id && existingBook.title == book.title;
      });
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }


  static Future<bool> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
      return true;
    } catch (e) {
      print('Error clearing favorites: $e');
      return false;
    }
  }
}
