import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImagePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ImagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('صورة من ملف'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Image.asset('assets/images/my_image.jpg'),
      ),
    );
  }
}
