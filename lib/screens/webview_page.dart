import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class WebViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Web Content Viewer'),
      ),
      body: Html(
        data: """
          <h1>Welcome to Flutter</h1>
          <p>This is a web content renderer using <strong>flutter_html</strong>.</p>
          <a href="https://flutter.dev">Visit Flutter Website</a>
        """,
      ),
    );
  }
}
