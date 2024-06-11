import 'package:flutter/material.dart';
import 'package:ob_havo/pages/ob_havo.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ObHavoPage(),
    );
  }
}
