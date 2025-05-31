import 'package:flutter/foundation.dart';
import 'dart:convert';

@immutable
class Book {
  final String id;
  final String title;
  final String primaryAuthor;
  final String? description;
  final String? thumbnailUrl;
  final int? pageCount;
  final String? language;
  final String? publisher;
  final double? rating;

  const Book({
    required this.id,
    required this.title,
    required this.primaryAuthor,
    this.description,
    this.thumbnailUrl,
    this.pageCount,
    this.language,
    this.publisher,
    this.rating,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        primaryAuthor: json['primaryAuthor'] ?? '',
        description: json['description'],
        thumbnailUrl: json['thumbnailUrl'],
        pageCount: json['pageCount'],
        language: json['language'],
        publisher: json['publisher'],
        rating: json['rating'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'primaryAuthor': primaryAuthor,
        'description': description,
        'thumbnailUrl': thumbnailUrl,
        'pageCount': pageCount,
        'language': language,
        'publisher': publisher,
        'rating': rating,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Book &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;

  Book copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    int? pageCount,
    String? primaryAuthor,
    String? language,
    String? publisher,
    double? rating,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      primaryAuthor: primaryAuthor ?? this.primaryAuthor,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      pageCount: pageCount ?? this.pageCount,
      language: language ?? this.language,
      publisher: publisher ?? this.publisher,
      rating: rating ?? this.rating,
    );
  }

  bool get hasThumbnail => thumbnailUrl != null && thumbnailUrl!.isNotEmpty;
}
