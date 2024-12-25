import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    // Initialize the WebView platform
    WebViewPlatform.instance?.clearCache();  // Remove this if it causes issues.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Web Content Viewer'),
      ),
      body: WebView(
        initialUrl: 'assets/rgb_cube_3d.html', // Ensure the path to the HTML file is correct.
        javascriptMode: JavascriptMode.unrestricted, // Allow JavaScript execution.
        onWebViewCreated: (WebViewController webViewController) {
          _webViewController = webViewController;
        },
      ),
    );
  }
}
