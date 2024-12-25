import 'package:flutter/material.dart';
import 'rgb_cube_page.dart'; // Import RGB Cube Page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RGB Cube Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RGBCubePage(), // Set RGBCubePage as the home page
    );
  }
} 