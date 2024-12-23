import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class RGBCubePage extends StatefulWidget {
  @override
  _RGBCubePageState createState() => _RGBCubePageState();
}

class _RGBCubePageState extends State<RGBCubePage> {
  List<double>? x, y, z;
  List<String>? hex;

  @override
  void initState() {
    super.initState();
    loadRGBData();
  }

  // Load RGB data from the assets
  Future<void> loadRGBData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/rgb_cube_data.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      setState(() {
        x = List<double>.from(jsonData['x']);
        y = List<double>.from(jsonData['y']);
        z = List<double>.from(jsonData['z']);
        hex = List<String>.from(jsonData['hex']);
      });
    } catch (e) {
      print('Error loading RGB data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while data is being fetched
    if (x == null || y == null || z == null || hex == null) {
      return Scaffold(
        appBar: AppBar(title: Text('3D RGB Cube')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('3D RGB Cube')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8, // Adjust based on desired resolution
        ),
        itemCount: hex!.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // On tap, show the RGB values in a dialog
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Color Details'),
                  content: Text('RGB: (${x![index].toInt()}, ${y![index].toInt()}, ${z![index].toInt()})\nHex: ${hex![index]}'),
                  actions: [
                    TextButton(
                      child: Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.all(2.0),
              color: Color(int.parse('0xFF${hex![index].substring(1)}')),
              child: Center(
                child: Text(
                  '(${x![index].toInt()}, ${y![index].toInt()}, ${z![index].toInt()})',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
