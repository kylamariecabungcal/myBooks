import 'package:flutter/material.dart';
import 'book_data.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final yearController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> submitBook() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        await BookData.addBook(
          titleController.text,
          authorController.text,
          yearController.text,
        );
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        String msg = e.toString();
        if (msg.contains('Failed host lookup')) {
          msg = 'Cannot connect to server. Is it running?';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add book: $msg')));
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Add Book'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.book),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: authorController,
                decoration: InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an author' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: yearController,
                decoration: InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.date_range),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a year' : null,
              ),
              const SizedBox(height: 24),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: submitBook,
                        icon: const Icon(Icons.save),
                        label: const Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
