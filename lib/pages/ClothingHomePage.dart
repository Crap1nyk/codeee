final GlobalKey<_ImageAreaState> _imageAreaKey = GlobalKey();

class ProfileScreen extends StatelessWidget {
  final Function(Uint8List) addImageToProducts;

  const ProfileScreen({Key? key, required this.addImageToProducts})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _PromptArea(),
              _ImageArea(key: _imageAreaKey),
              const SizedBox(height: 20.0),
              _FilterSliders(),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  final imageData = _imageAreaKey.currentState?.imageData;
                  if (imageData != null) {
                    globalImageData = imageData;
                    addImageToProducts(imageData);
                    final newProduct = {
                      'name': 'New Product',
                      'price': 0.0,
                      'image': imageData,
                      'category': 'New Category',
                    };
                    // products.add(newProduct); //product is added to categories
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      final userId = user.uid;
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('products')
                          .add(newProduct);

                      print("new product added to firebase");
                    }
                  }
                },
                child: const Text('Save Image Globally'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageArea extends StatefulWidget {
  const _ImageArea({Key? key}) : super(key: key);

  @override
  _ImageAreaState createState() => _ImageAreaState();
}

class _ImageAreaState extends State<_ImageArea> {
  Uint8List? imageData;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: imageData != null
          ? Image.memory(imageData!)
          : const Center(
              child: Text(
                'Output Image',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
    );
  }

  void updateImageData(Uint8List data) {
    setState(() {
      imageData = data;
    });
  }
}

class _FilterSliders extends StatefulWidget {
  @override
  _FilterSlidersState createState() => _FilterSlidersState();
}

class _FilterSlidersState extends State<_FilterSliders> {
  double _sliderValue1 = 0;
  double _sliderValue2 = 0;
  double _sliderValue3 = 0;
  double _sliderValue4 = 0;
  final double _sliderValue5 = 0;
  final double _sliderValue6 = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text('Filters'),
        Slider(
          value: _sliderValue1,
          onChanged: (newValue) {
            setState(() {
              _sliderValue1 = newValue;
            });
          },
          min: 0,
          max: 100,
          divisions: 100,
          label: 'Filter 1',
        ),
        Slider(
          value: _sliderValue2,
          onChanged: (newValue) {
            setState(() {
              _sliderValue2 = newValue;
            });
          },
          min: 0,
          max: 100,
          divisions: 100,
          label: 'Filter 2',
        ),
        Slider(
          value: _sliderValue3,
          onChanged: (newValue) {
            setState(() {
              _sliderValue3 = newValue;
            });
          },
          min: 0,
          max: 100,
          divisions: 100,
          label: 'Filter 3',
        ),
        Slider(
          value: _sliderValue4,
          onChanged: (newValue) {
            setState(() {
              _sliderValue4 = newValue;
            });
          },
          min: 0,
          max: 100,
          divisions: 100,
          label: 'Filter 4',
        ),
      ],
    );
  }
}

class _PromptArea extends StatefulWidget {
  @override
  _PromptAreaState createState() => _PromptAreaState();
}

class _PromptAreaState extends State<_PromptArea> {
  final TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: TextField(
        controller: _textFieldController,
        decoration: const InputDecoration(
          hintText: 'Enter prompt text...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: Icon(Icons.camera_alt),
        ),
        onSubmitted: (value) {
          _generateImageFromPrompt(value);
        },
      ),
    );
  }

  Future<void> _generateImageFromPrompt(String prompt) async {
    const apiUrl =
        "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0";
    const token = "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";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"inputs": prompt}),
      );

      if (response.statusCode == 200) {
        final Uint8List imageData = response.bodyBytes;
        _imageAreaKey.currentState?.updateImageData(imageData);
      } else {
        print("Failed to generate image: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception occurred: $e");
    }
  }
}