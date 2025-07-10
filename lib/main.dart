import 'package:flutter/material.dart';
import 'welcome_page.dart';

void main() {
  runApp(const BookApp());
}

class BookApp extends StatelessWidget {
  const BookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book Manager',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const WelcomePage(),
    );
  }
}
