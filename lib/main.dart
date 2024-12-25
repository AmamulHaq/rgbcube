import 'package:flutter/material.dart';
import 'rgb_cube_page.dart'; // Import RGB Cube Page
import 'webview_page.dart'; // Import WebViewPage

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
      home: WebViewPage(), // Set WebViewPage as the home page to load the 3D RGB Cube

      //home: RGBCubePage(), // Set RGBCubePage as the home page
    );
  }
}
