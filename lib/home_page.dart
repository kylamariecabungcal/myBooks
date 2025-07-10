import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_book_page.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List books = [];

  Future<void> fetchBooks() async {
    final res = await http.get(Uri.parse('http://10.0.2.2:3000/api/books'));
    if (res.statusCode == 200) {
      setState(() {
        books = jsonDecode(res.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text('📚 Book Viewer', style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return ListTile(
            title: Text(book['title']),
            subtitle: Text('${book['author']} (${book['publishedYear']})'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddBookPage()),
          );
          fetchBooks(); // Refresh on return
        },
      ),
    );
  }
}