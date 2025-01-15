import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const NewPage(),
    );
  }
}

class NewPage extends StatefulWidget {
  const NewPage({super.key});

  @override
  _NewPageState createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  final TextEditingController _imageUrlController = TextEditingController();
  bool _imageLoaded = false;
  bool _loading = false;
  String? _imageBase64;
  String? _errorMessage;
  String? _colorSample;
  String? _rgbDetails;
  String? _hexDetails;
  String? _positionDetails;
  String? _iframeId;
  String? _iframeUrl;
  bool _showIframe = false;
  String? _imagePath;
  Color _color = Colors.red;

  @override
  void initState() {
    super.initState();
    _iframeId = 'webview-${DateTime.now().millisecondsSinceEpoch}';
    ui.platformViewRegistry.registerViewFactory(
      _iframeId!,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..style.border = 'none'
          ..style.height = '100%'
          ..style.width = '100%'
          ..allowFullscreen = true
          ..allow =
              'accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture'
          ..setAttribute('sandbox', 'allow-scripts allow-same-origin');
        if (_iframeUrl != null) {
          iframe.src = _iframeUrl!;
        }
        return iframe;
      },
    );
  }

  void _updateImagePath() {
    setState(() {
      _imagePath = _imageUrlController.text;
    });
  }

  Future<void> _loadImageAndGenerateCube() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _showIframe = false;
    });

    try {
      final rgbResponse = await http.post(
        Uri.parse('http://127.0.0.1:5001/load_image'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': _imageUrlController.text.trim()}),
      );

      if (rgbResponse.statusCode == 200) {
        setState(() {
          _imageLoaded = true;
          _imageBase64 = jsonDecode(rgbResponse.body)['image'];
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load image for color picker: ${rgbResponse.body}';
        });
      }

      final cubeResponse = await http.post(
        Uri.parse('http://127.0.0.1:5000/generate_cube'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'imageUrl': _imageUrlController.text.trim()}),
      );

      if (cubeResponse.statusCode == 200) {
        final responseBody = json.decode(cubeResponse.body);
        final htmlBase64 = responseBody['cubeHtml'];
        if (htmlBase64 != null && htmlBase64 is String) {
          final decodedHtml = utf8.decode(base64Decode(htmlBase64));
          final blob = html.Blob([decodedHtml], 'text/html');
          final url = html.Url.createObjectUrlFromBlob(blob);
          setState(() {
            _iframeUrl = url;
            _showIframe = true;
          });
        } else {
          setState(() {
            _errorMessage =
                'Invalid response format from the server for 3D cube.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to generate cube: ${cubeResponse.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter Image URL',
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  ElevatedButton(
                    onPressed: _loadImageAndGenerateCube,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Image and Cube'),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red)),
              ),
            if (_imageLoaded)
              Container(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    MouseRegion(
                      onEnter: (_) {
                        _handleHover(128, 128);
                      },
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            _handleHover(details.localPosition.dx.toInt(),
                                details.localPosition.dy.toInt());
                          });
                        },
                        child: Container(
                          width: 256,
                          height: 256,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: MemoryImage(base64Decode(_imageBase64!)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_colorSample != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _positionDetails ?? 'Position: N/A',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    _rgbDetails ?? 'RGB: N/A',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    _hexDetails ?? 'Hex: N/A',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _colorSample != null
                                      ? Color(int.parse(_colorSample!
                                          .replaceFirst('#', '0xff')))
                                      : Colors.transparent,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (_showIframe)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  child: SizedBox(
                    width: 256,
                    height: 256,
                    child: HtmlElementView(viewType: _iframeId!),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleHover(int x, int y) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5001/get_pixel_info'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'x': x, 'y': y}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _colorSample = data['hex'];
        _rgbDetails = 'RGB(${data['r']}, ${data['g']}, ${data['b']})';
        _hexDetails = 'Hex: ${data['hex']}';
        _positionDetails = 'Position: ($x, $y)';
      });
    }
  }
}
