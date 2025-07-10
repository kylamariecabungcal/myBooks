import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final yearController = TextEditingController(); // NEW

  Future<void> submitBook() async {
    final response = await http.post(
      Uri.parse('https://example.com/books'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': titleController.text,
        'author': authorController.text,
        'year': yearController.text, // NEW
      }),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context); // Go back to HomePage
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add book')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('➕ Add Book')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) => value!.isEmpty ? 'Enter title' : null,
            ),
            TextFormField(
              controller: authorController,
              decoration: const InputDecoration(labelText: 'Author'),
              validator: (value) => value!.isEmpty ? 'Enter author' : null,
            ),
            TextFormField(
              controller: yearController,
              decoration: const InputDecoration(labelText: 'Year'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Enter year' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  submitBook();
                }
              },
              child: const Text('Submit'),
            ),
          ]),
        ),
      ),
    );
  }
}
