import 'dart:convert';
import 'package:http/http.dart' as http;

class Book {
  final String id;
  final String title;
  final String author;
  final String year;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.year,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'],
      title: json['title'],
      author: json['author'],
      year: json['year'],
    );
  }
}

class BookData {
  static const String baseUrl = 'http://localhost:3000/api/books';

  static Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  static Future<void> addBook(String title, String author, String year) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'title': title, 'author': author, 'year': year}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add book');
    }
  }

  static Future<void> deleteBook(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete book');
    }
  }
}
