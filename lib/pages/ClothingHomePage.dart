import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'product_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ClothingApp());
}

// List of items present in the categories section
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
      theme: ThemeData(primarySwatch: Colors.blue),
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
      const UserScreen(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'User'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home Page')),
    );
  }
}

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late User user;
  Map<String, dynamic> userInfo = {};

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      // Get a reference to the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Specify the location of the document in Firestore
      // Replace 'users' with the name of your collection and 'user_id' with the id of the current user
      DocumentReference docRef = firestore.collection('users').doc('user_id');

      // Get the document
      DocumentSnapshot docSnapshot = await docRef.get();

      // Check if the document exists before trying to read from it
      if (docSnapshot.exists) {
        // The document exists, you can safely read from it
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        // Use the data
      } else {
        // The document does not exist
        print('No document found for user');
      }
    } catch (e) {
      // Handle any errors that occur during the fetch
      print('Error fetching user info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        children: [
          if (userInfo.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (userInfo['photoUrl'] != null)
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(userInfo['photoUrl']),
                    ),
                  Text(userInfo['name'] ?? 'Name not available',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Gender: ${userInfo['gender'] ?? 'Not specified'}'),
                  Text('Phone: ${userInfo['phone'] ?? 'Not specified'}'),
                  Text('Wallet: \$${userInfo['walletAmount'] ?? 0}'),
                ],
              ),
            ),
          ListTile(
            title: const Text('My Orders'),
            leading: const Icon(Icons.shopping_bag),
            onTap: () {
              // Navigate to My Orders page
            },
          ),
          ListTile(
            title: const Text('Personal Info'),
            leading: const Icon(Icons.person),
            onTap: () {
              _showPersonalInfoDialog(context);
            },
          ),
          ListTile(
            title: const Text('FAQs'),
            leading: const Icon(Icons.help),
            onTap: () {
              // Navigate to FAQs page
            },
          ),
          ListTile(
            title: const Text('Wallet'),
            leading: const Icon(Icons.account_balance_wallet),
            onTap: () {
              // Navigate to Wallet page
            },
          ),
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.logout),
            onTap: () {
              FirebaseAuth.instance.signOut();
              // Navigate to Login page
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showPersonalInfoDialog(BuildContext context) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      setState(() {
        userInfo = doc.data()!;
      });
    }

    String? newName = userInfo['name'];
    String? newPhone = userInfo['phone'];
    String? newGender = userInfo['gender'];
    String? newAddress = userInfo['address'];
    String? newDob = userInfo['dob'];
    // String? newEmail = userInfo['email'];

    final _formKey = GlobalKey<FormState>();
    TextEditingController dobController = TextEditingController(text: newDob);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Personal Info'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: newName,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (value) => newName = value,
                  ),
                  TextFormField(
                    initialValue: newPhone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    onChanged: (value) => newPhone = value,
                  ),
                  DropdownButtonFormField<String>(
                    value: newGender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: <String>['Male', 'Female'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        newGender = value;
                      });
                    },
                  ),
                  TextFormField(
                    initialValue: newAddress,
                    decoration: const InputDecoration(labelText: 'Address'),
                    onChanged: (value) => newAddress = value,
                  ),
                  TextFormField(
                    controller: dobController,
                    decoration:
                        const InputDecoration(labelText: 'Date of Birth'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: newDob != null
                            ? DateTime.parse(newDob!)
                            : DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                        setState(() {
                          dobController.text = formattedDate;
                          newDob = formattedDate;
                        });
                      }
                    },
                  ),
                  // TextFormField(
                  //   initialValue: newEmail,
                  //   decoration: const InputDecoration(labelText: 'Email'),
                  //   onChanged: (value) => newEmail = value,
                  // ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await _updateUserInfo(
                      newName, newPhone, newGender, newAddress, newDob);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserInfo(
    String? newName,
    String? newPhone,
    String? newGender,
    String? newAddress,
    String? newDob,
  ) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await docRef.set({
        'name': newName,
        'phone': newPhone,
        'gender': newGender,
        'address': newAddress,
        'dob': newDob,
      });

      // Update display name and email in FirebaseAuth
      if (newName != null) {
        await user.updateDisplayName(newName);
      }
      // Update phone number if applicable (this requires re-authentication with phone credentials)
      if (newPhone != null) {
        // Re-authentication and phone number update logic goes here
      }

      // Reload user to get updated data
      await user.reload();
      setState(() {
        user = FirebaseAuth.instance.currentUser!;
        // _fetchUserInfo(); // Refresh the user info displayed
      });
    } catch (e) {
      print('Error updating user info: $e');
    }
  }
}

class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cart;
  final List<Uint8List> products = [];

  CartScreen({Key? key, required this.cart}) : super(key: key);

  void addProduct(Uint8List product) {
    products.add(product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('products')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading');
          }

          final cart =
              snapshot.data?.docs.map((doc) => doc.data()).toList() ?? [];

          return cart.isEmpty
              ? const Center(child: Text('Your cart is empty'))
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
                          contentPadding: const EdgeInsets.all(20.0),
                          leading: item['image'] is List
                              ? Image.memory(
                                  Uint8List.fromList(
                                      (item['image'] as List).cast<int>()),
                                  width: 200,
                                  height: 200,
                                )
                              : null,
                          title: Text(item['name'].toString()),
                          subtitle: Text('\$${item['price'].toString()}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductPage(product: item),
                              ),
                            );
                          },
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
                onPressed: () {},
                child: const Text('Checkout'),
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
      appBar: AppBar(title: const Text('Profile')),
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
                  ? Image.memory(globalImageData!, width: 200, height: 200)
                  : const SizedBox.shrink(),
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

  void updateImageData(Uint8List data) {
    setState(() {
      imageData = data;
    });
  }

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
              child: Text('Output Image', style: TextStyle(fontSize: 20.0))),
    );
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
