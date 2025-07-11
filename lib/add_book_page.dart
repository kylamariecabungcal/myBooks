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

        if (!mounted) return;

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text('Success'),
              ],
            ),
            content: const Text('Book successfully added!'),
          ),
        );

        // Auto dismiss after 2 seconds and go back
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop(); // Close dialog
            Navigator.of(context).pop(true); // Go back to previous screen
          }
        });
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
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        title: const Text('Add Book'),
        backgroundColor: Colors.indigo,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Enter Book Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildTextField(
                      controller: titleController,
                      label: 'Title',
                      icon: Icons.book,
                      validatorMsg: 'Please enter a title',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: authorController,
                      label: 'Author',
                      icon: Icons.person,
                      validatorMsg: 'Please enter an author',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: yearController,
                      label: 'Year',
                      icon: Icons.date_range,
                      keyboardType: TextInputType.number,
                      validatorMsg: 'Please enter a year',
                    ),
                    const SizedBox(height: 30),
                    _isSubmitting
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: submitBook,
                              icon: const Icon(Icons.save),
                              label: const Text(
                                'Submit',
                                style: TextStyle(fontSize: 16),
                              ),
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
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String validatorMsg,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon),
      ),
      validator: (value) => value!.isEmpty ? validatorMsg : null,
    );
  }
}
