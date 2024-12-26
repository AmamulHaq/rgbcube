import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late String _iframeElementId;

  @override
  void initState() {
    super.initState();

    // Generate a unique ID for the iframe element
    _iframeElementId = 'webview-${DateTime.now().millisecondsSinceEpoch}';

    // Dynamically resolve the platformViewRegistry
    final dynamic platformViewRegistry = _getPlatformViewRegistry();

    if (platformViewRegistry != null) {
      platformViewRegistry.registerViewFactory(
        _iframeElementId,
        (int viewId) => html.IFrameElement()
          ..src = 'assets/rgb_cube_3d.html' // Ensure this is the correct relative path.
          ..style.border = 'none'
          ..allowFullscreen = true
          ..allow = 'accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture'
          ..setAttribute('sandbox', 'allow-scripts allow-same-origin'),
      );
    } else {
      throw Exception("Platform view registry not found. Ensure this is running on Flutter Web.");
    }
  }

  dynamic _getPlatformViewRegistry() {
    // Dynamically resolve `ui.platformViewRegistry` for flexibility.
    try {
      var platformViewRegistry2 = ui.platformViewRegistry;
      var platformViewRegistry = platformViewRegistry2;
      return platformViewRegistry;
    } catch (e) {
      print("PlatformViewRegistry not available: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Web Content Viewer'),
      ),
      body: HtmlElementView(viewType: _iframeElementId),
    );
  }
}
