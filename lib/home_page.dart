import 'package:flutter/material.dart';
import 'add_book_page.dart';
import 'edit_book_page.dart';
import 'book_data.dart';
import 'welcome_page.dart'; // ✅ Added import

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? _sortBy;
  List<Book> books = [];
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    try {
      final fetchedBooks = await BookData.fetchBooks();
      if (mounted) {
        setState(() => books = fetchedBooks);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading books: $e')));
      }
    }
  }

  List<Book> getSortedBooks() {
    final sorted = List.of(books);
    if (_sortBy == 'title') {
      sorted.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    } else if (_sortBy == 'year') {
      sorted.sort(
        (a, b) =>
            int.tryParse(a.year)?.compareTo(int.tryParse(b.year) ?? 0) ?? 0,
      );
    }
    return sorted;
  }

  void showAnimatedSuccess(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, iconValue, child) {
                    return Row(
                      children: [
                        Transform.scale(
                          scale: iconValue,
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Success',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                content: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, textValue, child) {
                    return Opacity(
                      opacity: textValue,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - textValue)),
                        child: Text(
                          message,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );

    // Auto dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedBooks = getSortedBooks();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade600,
        leading: IconButton(
          // ✅ Added arrow back button
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WelcomePage()),
            );
          },
        ),
        title: const Text(
          '📖 Book Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _sortBy = value),
            icon: const Icon(Icons.sort, color: Colors.white),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'title', child: Text('Sort by Title')),
              PopupMenuItem(value: 'year', child: Text('Sort by Year')),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: books.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text('No books added yet', style: TextStyle(fontSize: 18)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedBooks.length,
              itemBuilder: (context, index) {
                final book = sortedBooks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Row(
                            children: [
                              const Icon(
                                Icons.book,
                                color: Colors.indigo,
                                size: 30,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  book.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (book.imageUrl != null) ...[
                                Center(
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        'http://localhost:3000${book.imageUrl}',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.image,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              _buildDetailRow('Author', book.author),
                              const SizedBox(height: 12),
                              _buildDetailRow('Year', book.year),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                Navigator.pop(context); // Close modal
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditBookPage(
                                      bookId: book.id,
                                      title: book.title,
                                      author: book.author,
                                      year: book.year,
                                      imageUrl: book.imageUrl,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  await loadBooks();
                                }
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      leading: const Icon(Icons.book, color: Colors.indigo),
                      title: Text(
                        book.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Author: ${book.author}\nYear: ${book.year}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: _isDeleting
                            ? null
                            : () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete Book'),
                                    content: const Text(
                                      'Are you sure you want to delete this book?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          setState(() => _isDeleting = true);
                                          try {
                                            await BookData.deleteBook(book.id);
                                            await loadBooks();

                                            if (mounted) {
                                              showAnimatedSuccess(
                                                'Book was successfully deleted.',
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Failed to delete book: $e',
                                                  ),
                                                ),
                                              );
                                            }
                                          } finally {
                                            if (mounted)
                                              setState(
                                                () => _isDeleting = false,
                                              );
                                          }
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBookPage()),
          );
          if (result == true) {
            await loadBooks();
          }
        },
      ),
    );
  }
}
