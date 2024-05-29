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
      CategoriesScreen(
          addProductUsingGlobalImage: _addProductUsingGlobalImage,
          addToCart: _addToCart),
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

// saves the image in device
  Future<String> saveImage(Uint8List imageData) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/global_image.jpg';
    final File imageFile = File(filePath);
    await imageFile.writeAsBytes(imageData);
    return filePath;
  }

// adding new product to product list
  void _addProductUsingGlobalImage(Uint8List imageData) async {
    final String imagePath = await saveImage(imageData);
    products.add({
      'name': 'Globally Saved Image',
      'price': 0.0,
      'image': imagePath,
      'category': 'Accessories',
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      cart.add(product);
    });
  }

// creating the bottom navigation bar
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
            icon: Icon(Icons.category),
            label: 'Categories',
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

class CategoriesScreen extends StatefulWidget {
  final Function(Uint8List)? addProductUsingGlobalImage;
  final Function(Map<String, dynamic>)? addToCart;

  const CategoriesScreen(
      {Key? key, this.addProductUsingGlobalImage, this.addToCart})
      : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _selectedCategoryIndex = 0;

  final List<String> categories = [
    'All categories',
    'Shirts',
    'Pants',
    'Dresses',
    'Jackets',
    'Accessories',
  ];

  List<Map<String, dynamic>> favorites = [];

  List<Map<String, dynamic>> getFilteredProducts() {
    if (_selectedCategoryIndex == 0) {
      return products;
    } else {
      final String selectedCategory = categories[_selectedCategoryIndex];
      return products
          .where((product) => product['category'] == selectedCategory)
          .toList();
    }
  }

  void addToFavorites(Map<String, dynamic> product) {
    setState(() {
      if (!favorites.contains(product)) {
        favorites.add(product);
      } else {
        favorites.remove(product);
      }
    });
  }

  void _addProductUsingGlobalImage() {
    if (widget.addProductUsingGlobalImage != null && globalImageData != null) {
      widget.addProductUsingGlobalImage!(globalImageData!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Categories',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                  label: Text(categories[index]),
                  selected: _selectedCategoryIndex == index,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategoryIndex = selected ? index : 0;
                    });
                  },
                ),
              );
            },
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: 0.75,
            ),
            itemCount: getFilteredProducts().length,
            itemBuilder: (BuildContext context, int index) {
              final product = getFilteredProducts()[index];
              return ProductItem(
                name: product['name'],
                price: product['price'],
                image: product['image'],
                addToCart: () => widget.addToCart!(product), // Change this line
                addToFavorites: () => addToFavorites(product),
                isFavorite: favorites.contains(product),
              );
            },
          ),
        ),
        GestureDetector(
          onTap: _addProductUsingGlobalImage,
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Text(
              'Add Product with Global Image',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class ProductItem extends StatelessWidget {
  final String name;
  final double price;
  final String image;
  final VoidCallback addToCart;
  final VoidCallback addToFavorites;
  final bool isFavorite;

  const ProductItem({
    Key? key,
    required this.name,
    required this.price,
    required this.image,
    required this.addToCart,
    required this.addToFavorites,
    required this.isFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                'assets/images/$image',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.0),
                Text('\$$price'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
                      onPressed: addToFavorites,
                    ),
                    IconButton(
                      icon: Icon(Icons.add_shopping_cart),
                      onPressed: addToCart,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
                              20.0), // Adjust content padding here
                          leading: item != null
                              ? (item['image'] is List
                                  ? Image.memory(
                                      Uint8List.fromList(
                                          (item['image'] as List).cast<int>()),
                                      width: 200, // Adjust the width as needed
                                      height:
                                          200, // Adjust the height as needed
                                    )
                                  : null) // handle non-list image data here
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
                  // Add your checkout logic here
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

class ProductDetailPage extends StatelessWidget {
  final String name;
  final double price;
  final String image;

  ProductDetailPage({
    required this.name,
    required this.price,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Detail'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/$image',
              width: double.infinity,
              height: 200.0,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16.0),
            Text(
              name,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              '\$$price',
              style: TextStyle(fontSize: 18.0, color: Colors.blue),
            ),
            SizedBox(height: 16.0),
            Text(
              'Product Description:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Add your product description here...',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
