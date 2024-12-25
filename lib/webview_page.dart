/*import 'package:flutter/material.dart';
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
    // Initialize WebView when the widget is created
    WebViewPlatform.instance?.clearCache();  // This line should be removed if you're using a newer version.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Web Content Viewer'),
      ),
      body: WebView(
        initialUrl: 'assets/rgb_cube_3d.html',  // Make sure the path to HTML is correct.
        javascriptMode: JavascriptMode.unrestricted,  // Allow JavaScript execution.
        onWebViewCreated: (WebViewController webViewController) {
          _webViewController = webViewController;
        },
      ),
    );
  }
}

*/
