import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Async Request Example'),
        ),
        body: TextToImageWidget(),
      ),
    );
  }
}

class TextToImageWidget extends StatefulWidget {
  @override
  _TextToImageWidgetState createState() => _TextToImageWidgetState();
}

class _TextToImageWidgetState extends State<TextToImageWidget> {
  final TextEditingController _controller = TextEditingController();
  Uint8List? _imageBytes;
  bool _loading = false;

  Future<void> _generateImage(String prompt) async {
    setState(() {
      _loading = true;
    });

    final url = Uri.parse('https://fragger246-mockupgen.hf.space/call/infer');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "data": [
          'single',
          "red",
          "shirt",
          "floral",
          "hanging on the plain wall",
          "none", // Assuming "none" as a placeholder for the negative prompt
          0,
          true,
          256,
          256,
          0,
          1
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey('event_id')) {
        final eventId = data['event_id'];
        _pollForResult(eventId);
      } else {
        setState(() {
          _loading = false;
        });
        print("Unexpected response format: ${response.body}");
      }
    } else {
      setState(() {
        _loading = false;
      });
      print("Failed to generate image: ${response.body}");
    }
  }

  Future<void> _pollForResult(String eventId) async {
    final url =
        Uri.parse('https://fragger246-mockupgen.hf.space/call/result/$eventId');
    bool resultReady = false;

    while (!resultReady) {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print("Polling result response: $responseBody");

        // Split the response by lines
        final lines = responseBody.split('\n');

        for (int i = 0; i < lines.length; i++) {
          print("Processing line: ${lines[i]}");

          if (lines[i].startsWith('event: ')) {
            final event =
                lines[i].substring(6).trim(); // Extract the event type
            print("Event type: $event");

            if (event == 'complete') {
              // Find the next line containing JSON data
              print("Complete event received, parsing data...");
              if (i + 1 < lines.length && lines[i + 1].startsWith('data: ')) {
                final dataLine = lines[i + 1];
                print("Data line: $dataLine");

                if (dataLine.isNotEmpty) {
                  try {
                    // Remove 'data: ' prefix and parse the JSON
                    final jsonString = dataLine.substring(5).trim();
                    print("JSON string: $jsonString");

                    if (jsonString.isNotEmpty && jsonString != 'null') {
                      final jsonData = jsonDecode(jsonString);

                      if (jsonData != null &&
                          jsonData is List &&
                          jsonData.isNotEmpty) {
                        final imageUrl =
                            jsonData[0]['url']; // Extract the image URL
                        print("Image URL: $imageUrl");

                        final imageResponse =
                            await http.get(Uri.parse(imageUrl));
                        if (imageResponse.statusCode == 200) {
                          setState(() {
                            _imageBytes = imageResponse.bodyBytes;
                            _loading = false;
                            resultReady = true;
                          });
                        } else {
                          print(
                              "Failed to download image: ${imageResponse.body}");
                          setState(() {
                            _loading = false;
                          });
                          resultReady = true;
                        }
                      } else {
                        print("No valid data found.");
                        setState(() {
                          _loading = false;
                        });
                        resultReady = true;
                      }
                    } else {
                      print("Data is empty or 'null'.");
                      setState(() {
                        _loading = false;
                      });
                      resultReady = true;
                    }
                  } catch (e) {
                    print("Error parsing JSON data: $e");
                    print("Response body: ${dataLine}");
                    setState(() {
                      _loading = false;
                    });
                    resultReady = true;
                  }
                } else {
                  print("Data line is empty.");
                  setState(() {
                    _loading = false;
                  });
                  resultReady = true;
                }
              }
            } else if (event == 'heartbeat') {
              // Continue polling
              await Future.delayed(Duration(seconds: 5));
            }
          }
        }
      } else {
        setState(() {
          _loading = false;
        });
        print("Failed to retrieve result: ${response.body}");
        resultReady = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Enter prompt'),
              enabled: !_loading,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () {
                      _generateImage(_controller.text);
                    },
              child: _loading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Text('Generate'),
            ),
            SizedBox(height: 16.0),
            if (_imageBytes != null)
              Expanded(
                child: Image.memory(_imageBytes!),
              ),
            if (_loading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Generating image, please wait...'),
              ),
          ],
        ),
      ),
    );
  }
}
