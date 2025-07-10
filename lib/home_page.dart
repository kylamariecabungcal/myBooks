import 'package:flutter/material.dart';
import 'add_book_page.dart';
import 'book_data.dart';

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

  @override
  Widget build(BuildContext context) {
    final sortedBooks = getSortedBooks();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade600,
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
                                            setState(() => _isDeleting = false);
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
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Book added successfully')),
              );
            }
          }
        },
      ),
    );
  }
}
