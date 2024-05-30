import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:part3/pages/SignupScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(const ClothingApp());
}

// list of items present in the categories section
List<Map<String, dynamic>> products = [
  {
    'name': 'Product 1',
    'price': 20.0,
    'image': 'jacket.jpg',
    'category': 'Jackets'
  },
  {
    'name': 'Product 2',
    'price': 30.0,
    'image': 'jacketw.jpeg',
    'category': 'Jackets'
  },
  {
    'name': 'Product 3',
    'price': 25.0,
    'image': 'jeans.jpeg',
    'category': 'Pants'
  },
  {
    'name': 'Product 4',
    'price': 40.0,
    'image': 'shirt.jpeg',
    'category': 'Shirts'
  },
  {
    'name': 'Product 5',
    'price': 35.0,
    'image': 'shirtw.jpeg',
    'category': 'Shirts'
  },
];

Uint8List? globalImageData;

class ClothingApp extends StatelessWidget {
  const ClothingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clothing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ClothingHomePage(),
    );
  }
}

class ClothingHomePage extends StatefulWidget {
  const ClothingHomePage({Key? key}) : super(key: key);

  @override
  _ClothingHomePageState createState() => _ClothingHomePageState();
}

class _ClothingHomePageState extends State<ClothingHomePage> {
  int _selectedIndex = 0;
  late List<Map<String, dynamic>> cart;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    cart = [];
    _widgetOptions = <Widget>[
      const HomePage(),
      UserScreen(),
      CartScreen(cart: cart),
      ProfileScreen(addImageToProducts: _addImageToProducts),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addImageToProducts(Uint8List imageData) async {
    setState(() {
      globalImageData = imageData;
      _widgetOptions[3] =
          ProfileScreen(addImageToProducts: _addImageToProducts);
    });
  }

  Future<String> saveImage(Uint8List imageData) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/global_image.jpg';
    final File imageFile = File(filePath);
    await imageFile.writeAsBytes(imageData);
    return filePath;
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      cart.add(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'User',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Home Page'),
      ),
    );
  }
}

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle,
              size: 100,
              color: Colors.grey[700],
            ),
            SizedBox(height: 20),
            Text(
              'User Information',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add user-related actions here
              },
              child: Text('User Actions'),
            ),
          ],
        ),
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cart;
  final List<Uint8List> products = [];

  void addProduct(Uint8List product) {
    products.add(product);
  }

  CartScreen({Key? key, required this.cart}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('products')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          final cart =
              snapshot.data?.docs.map((doc) => doc.data()).toList() ?? [];

          return cart.isEmpty
              ? const Center(
                  child: Text('Your cart is empty'),
                )
              : ListView.builder(
                  itemCount: cart.length,
                  itemBuilder: (context, index) {
                    final item = cart[index] as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Card(
                        elevation: 20,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(
                              20.0),
                          leading: item != null
                              ? (item['image'] is List
                                  ? Image.memory(
                                      Uint8List.fromList(
                                          (item['image'] as List).cast<int>()),
                                      width: 200,
                                      height: 200,
                                    )
                                  : null)
                              : null,
                          title: Text(
                              (item['name'] is String ? item['name'] : '')
                                  .toString()),
                          subtitle: Text(
                              '\$${(item['price'] is num ? item['price'] : 0).toString()}'),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                },
                child: Text('Checkout'),
              ),
            ),
    );
  }
}

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
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      final userId = user.uid;
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('products')
                          .add(newProduct);
                    }
                  }
                },
                child: const Text('Add Image to Products'),
              ),
              const SizedBox(height: 20.0),
              globalImageData != null
                  ? Image.memory(
                      globalImageData!,
                      width: 200,
                      height: 200,
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptArea extends StatefulWidget {
  @override
  _PromptAreaState createState() => _PromptAreaState();
}

class _PromptAreaState extends State<_PromptArea> {
  final TextEditingController _promptController = TextEditingController();

  String _response = '';

  void _generateImage() async {
    final String apiKey = 'YOUR_API_KEY';
    final String prompt = _promptController.text;

    if (prompt.isNotEmpty) {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'image-alpha-001',
          'prompt': prompt,
          'num_images': 1,
          'size': '1024x1024',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final imageUrl = responseData['data'][0]['url'];
        final imageResponse = await http.get(Uri.parse(imageUrl));
        final imageData = imageResponse.bodyBytes;
        _imageAreaKey.currentState?.updateImage(imageData);

        setState(() {
          _response = 'Image generated successfully!';
        });
      } else {
        setState(() {
          _response = 'Failed to generate image';
        });
      }
    } else {
      setState(() {
        _response = 'Please enter a prompt';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _promptController,
            decoration: const InputDecoration(labelText: 'Enter a prompt'),
          ),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: _generateImage,
            child: const Text('Generate Image'),
          ),
          const SizedBox(height: 10.0),
          Text(_response),
        ],
      ),
    );
  }
}

class _ImageArea extends StatefulWidget {
  _ImageArea({Key? key}) : super(key: key);

  @override
  _ImageAreaState createState() => _ImageAreaState();

  void updateImage(Uint8List imageData) {
    _imageAreaKey.currentState?.updateImage(imageData);
  }

  Uint8List? get imageData => _imageAreaKey.currentState?.imageData;
}

class _ImageAreaState extends State<_ImageArea> {
  Uint8List? _imageData;

  Uint8List? get imageData => _imageData;

  void updateImage(Uint8List imageData) {
    setState(() {
      _imageData = imageData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 20.0),
        _imageData != null
            ? Image.memory(
                _imageData!,
                width: 200,
                height: 200,
              )
            : const Placeholder(
                fallbackWidth: 200.0,
                fallbackHeight: 200.0,
              ),
      ],
    );
  }
}

class _FilterSliders extends StatefulWidget {
  @override
  _FilterSlidersState createState() => _FilterSlidersState();
}

class _FilterSlidersState extends State<_FilterSliders> {
  double _brightness = 0;
  double _contrast = 1;

  void _applyFilters() async {
    final imageData = _imageAreaKey.currentState?.imageData;
    if (imageData != null) {
      final result = await FlutterImageCompress.compressWithList(
        imageData,
        quality: 100,
      );

      setState(() {
        _imageAreaKey.currentState?.updateImage(Uint8List.fromList(result));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text('Brightness'),
        Slider(
          value: _brightness,
          min: -1,
          max: 1,
          onChanged: (value) {
            setState(() {
              _brightness = value;
            });
          },
        ),
        const Text('Contrast'),
        Slider(
          value: _contrast,
          min: 0,
          max: 4,
          onChanged: (value) {
            setState(() {
              _contrast = value;
            });
          },
        ),
        ElevatedButton(
          onPressed: _applyFilters,
          child: const Text('Apply Filters'),
        ),
      ],
    );
  }
}
