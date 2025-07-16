import 'dart:convert';
import 'package:http/http.dart' as http;

class Book {
  final String id;
  final String title;
  final String author;
  final String year;
  final String? imageUrl;
  final String? prologue;
  final bool read;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.year,
    this.imageUrl,
    this.prologue,
    this.read = false,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      author: json['author'],
      year: json['year'],
      imageUrl: json['imageUrl'],
      prologue: json['prologue'],
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'year': year,
      'imageUrl': imageUrl,
      'prologue': prologue,
      'read': read,
    };
  }
}

class BookData {
  // NOTE: If you are using a real device, replace the IP below with your computer's local network IP address (e.g., 192.168.1.5)
  static const String baseUrl = 'http://192.168.193.69:3000/api/books';

  static Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load books: ${response.statusCode}');
    }
  }

  static Future<void> addBook(
    String title,
    String author,
    String year, [
    String? imagePath,
  ]) async {
    print('BookData.addBook called with imagePath: $imagePath');

    var request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.fields['title'] = title;
    request.fields['author'] = author;
    request.fields['year'] = year;

    if (imagePath != null) {
      print('Adding image file: $imagePath');
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    } else {
      print('No image path provided');
    }

    final response = await request.send();
    if (response.statusCode != 201) {
      String msg = 'Failed to add book';
      try {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);
        msg = jsonResponse['error'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
    }
  }

  static Future<void> deleteBook(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 404) {
      throw Exception('Book not found');
    }
    if (response.statusCode != 204) {
      throw Exception('Failed to delete book: ${response.statusCode}');
    }
  }

  static Future<void> updateBook(
    String id,
    String title,
    String author,
    String year,
    String? imagePath,
  ) async {
    print('Updating book with ID: $id');
    print('Update data: title=$title, author=$author, year=$year');
    // When sending data to the backend, do not include prologue
    // Example (if using a map):
    // final data = {
    //   'title': title,
    //   'author': author,
    //   'year': year,
    //   'imagePath': imagePath,
    // };
  }
}
