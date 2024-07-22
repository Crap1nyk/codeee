import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:part3/models/community_model.dart';
import 'product_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'dart:io'; // For File handling
import 'package:cupertino_icons/cupertino_icons.dart';

// Entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Initialize Firebase app
  runApp(const ClothingApp()); // Run the Flutter application
}

// Sample product data (replace with your actual data handling logic)
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

// Global variable to store image data (for demonstration purposes)
Uint8List? globalImageData;

// Main application widget
class ClothingApp extends StatelessWidget {
  const ClothingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clothing App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home:
          const ClothingHomePage(), // Set ClothingHomePage as the initial route
    );
  }
}

// Stateful widget for the home page
class ClothingHomePage extends StatefulWidget {
  const ClothingHomePage({Key? key}) : super(key: key);

  @override
  _ClothingHomePageState createState() => _ClothingHomePageState();
}

// State class for ClothingHomePage
class _ClothingHomePageState extends State<ClothingHomePage> {
  int _selectedIndex =
      0; // Index for current selected bottom navigation bar item
  late List<Map<String, dynamic>> cart; // List to store items in cart
  late List<Widget>
      _widgetOptions; // List of widget options for bottom navigation bar items

  @override
  void initState() {
    super.initState();
    cart = []; // Initialize cart as empty list
    _widgetOptions = <Widget>[
      const HomePage(), // Home page widget
      const UserScreen(), // User profile screen
      CartScreen(cart: cart), // Cart screen with current cart items
      ProfileScreen(
          addImageToProducts:
              _addImageToProducts), // Profile screen with image upload
    ];
  }

  // Function to handle bottom navigation bar item tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Set selected index to the tapped item index
    });
  }

  // Function to add image data to products (for demonstration purposes)
  void _addImageToProducts(Uint8List imageData) async {
    setState(() {
      globalImageData = imageData; // Set global image data
      _widgetOptions[3] = ProfileScreen(
          addImageToProducts:
              _addImageToProducts); // Update profile screen with new image
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex), // Display selected widget
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Home'), // Home icon and label
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'User'), // User icon and label
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart'), // Cart icon and label
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile'), // Profile icon and label
        ],
        currentIndex: _selectedIndex, // Current index of selected item
        selectedItemColor: Colors.blue, // Color of selected item
        onTap: _onItemTapped, // Function to handle item tap
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Community Page when floating action button is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CommunityPage()),
          );
        },
        child: const Icon(Icons.group), // Group icon for floating action button
      ),
    );
  }
}

// Sample Home page widget

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  User? _user;
  String? _userName;
  String? _userPhotoUrl;

  final List<String> _section1Images = [
    'assets/images/naruto.jpg',
    'assets/images/sanemi.jpg',
    'assets/images/satan.jpg',
    'assets/images/zoro.jpg',
  ];

  final List<String> _section2Images = [
    'assets/images/saree.jpg',
    'assets/images/kurta.jpg',
    'assets/images/suit.jpg',
    'assets/images/lehenga.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _userName = _user!.displayName;
      _userPhotoUrl = _user!.photoURL;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    try {
      if (_user == null) {
        print('User not logged in');
        return;
      }

      String uid = _user!.uid;
      String uniquePostId =
          FirebaseFirestore.instance.collection('posts').doc().id;
      String filePath = 'posts/$uid/$uniquePostId.png';

      UploadTask uploadTask =
          FirebaseStorage.instance.ref(filePath).putFile(_image!);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(uniquePostId)
          .set({
        'uid': uid,
        'downloadUrl': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Upload successful. Download URL: $downloadUrl');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to cart screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _userPhotoUrl != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(_userPhotoUrl!),
                          radius: 30,
                        )
                      : CircleAvatar(
                          child: Icon(Icons.person),
                          radius: 30,
                        ),
                  SizedBox(width: 16),
                  Text(
                    _userName ?? 'User',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            _imageBanner(),
            _sectionBanner('Anime and Vectors Arts'),
            _gridSection(_section1Images),
            _sectionBanner2('Traditionals'),
            _gridSection(_section2Images),
          ],
        ),
      ),
    );
  }

  Widget _imageBanner() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 150,
        width: 300,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/banner.png'), 
            // Replace with your banner image
            fit: BoxFit.contain,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _sectionBanner(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 10),
          Container(
            height: 100,
            width:300,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/anime.jpeg'), // Replace with your section banner image
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

Widget _sectionBanner2(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 10),
          Container(
            height: 100,
            width:300,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/tradition.jpeg'), // Replace with your section banner image
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
  Widget _gridSection(List<String> images) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(images[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
// Stateful widget for user profile screen
class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late User user; // Firebase user object
  Map<String, dynamic> userInfo = {}; // Map to store user information
  File? _image; // Variable to store the selected image

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!; // Get current Firebase user
    _fetchUserInfo(); // Fetch user information
  }

  // Function to fetch user information from Firestore
  Future<void> _fetchUserInfo() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference docRef = firestore.collection('users').doc(user.uid);
      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        setState(() {
          userInfo = docSnapshot.data() as Map<String, dynamic>;
        });
      } else {
        print('No document found for user');
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

@override
Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color.fromARGB(255, 0, 0, 0), Color.fromARGB(255, 50, 50, 50)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Scaffold(
      backgroundColor: Colors.transparent, // Make Scaffold background transparent
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)), // White text for app bar title
        backgroundColor: Colors.transparent,
        elevation: 0, // No shadow
        iconTheme: IconThemeData(color: Colors.white), // White icons
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Rounded UI with user image and information
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromRGBO(208, 108, 236, 1), Color.fromARGB(255, 89, 0, 255)], // Gradient colors
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[800], // Darker grey for the avatar background
                    backgroundImage: _image != null
                        ? FileImage(_image!) as ImageProvider
                        : (userInfo['photoUrl'] != null
                            ? NetworkImage(userInfo['photoUrl']!)
                            : null) as ImageProvider?,
                    child: _image == null && userInfo['photoUrl'] == null
                        ? Icon(Icons.camera_alt, color: Colors.white)
                        : null,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  userInfo['name'] ?? 'Name not available',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Gender: ${userInfo['gender'] ?? 'Not specified'}',
                  style: TextStyle(color: Colors.white70), // Slightly lighter text color
                ),
                Text(
                  'Phone: ${userInfo['phone'] ?? 'Not specified'}',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  'Wallet: \$${userInfo['walletAmount'] ?? 0}',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Container for list tiles
          Container(
            decoration: BoxDecoration(
              color: Colors.black, // Solid black background for the list tiles container
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildListTile(CupertinoIcons.bag_fill, 'My Orders', () {
                  // Navigate to My Orders page
                }),
                _buildListTile(CupertinoIcons.person_fill, 'Personal Info', () {
                  _showPersonalInfoDialog(context); // Show personal info dialog
                }),
                _buildListTile(CupertinoIcons.question_circle_fill, 'FAQs', () {
                  // Navigate to FAQs page
                }),
                _buildListTile(CupertinoIcons.money_dollar_circle, 'Wallet', () {
                  // Navigate to Wallet page
                }),
                _buildListTile(CupertinoIcons.arrow_right_circle_fill, 'Logout', () {
                  FirebaseAuth.instance.signOut(); // Sign out current user
                  // Navigate to Login page
                }),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Function to create list tiles with border
ListTile _buildListTile(IconData icon, String title, VoidCallback onTap) {
  return ListTile(
    title: Text(
      title,
      style: TextStyle(color: Colors.white),
    ),
    leading: Icon(icon, color: Colors.white),
    onTap: onTap,
    tileColor: Colors.black, // Black background for list tiles
    shape: RoundedRectangleBorder(
      side: BorderSide(color: Colors.white24, width: 1), // Border color and width
      borderRadius: BorderRadius.circular(12.0),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  );
}
  // Function to show personal info dialog
  Future<void> _showPersonalInfoDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    TextEditingController dobController = TextEditingController(text: userInfo['dob']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Personal Info'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextFormField('Name', 'name'),
                  _buildTextFormField('Phone', 'phone'),
                  DropdownButtonFormField<String>(
                    value: userInfo['gender'],
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: <String>['Male', 'Female', 'Other']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) => userInfo['gender'] = value,
                  ),
                  _buildTextFormField('Address', 'address'),
                  TextFormField(
                    controller: dobController,
                    decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)'),
                    onChanged: (value) => userInfo['dob'] = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your date of birth';
                      }
                      return null;
                    },
                  ),
                  _buildTextFormField('Email', 'email', isEmail: true),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .update(userInfo);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Updated successfully')),
                  );
                  setState(() {}); // Refresh the UI
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Helper function to create text form fields
  Widget _buildTextFormField(String label, String key, {bool isEmail = false}) {
    return TextFormField(
      initialValue: userInfo[key] ?? '',
      decoration: InputDecoration(labelText: label),
      onChanged: (value) => userInfo[key] = value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        if (isEmail && (!value.contains('@') || !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value))) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
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

class ProfileScreen extends StatefulWidget {
  final Function(Uint8List) addImageToProducts;

  const ProfileScreen({Key? key, required this.addImageToProducts}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedModel = 'Model 1'; // Default selected model

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 33, 32, 32),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DropdownButton<String>(
                  value: _selectedModel,
                  dropdownColor: Colors.grey[850],
                  items: <String>['Model 1', 'Model 2', 'Model 3'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedModel = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 20.0),
                _selectedModel == 'Model 1' ? _model1UI() : (_selectedModel == 'Model 2' ? _model2UI() : _model3UI()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _model1UI() {
    return Column(
      children: <Widget>[
        _PromptArea(),
        ElevatedButton.icon(
          icon: Icon(Icons.auto_awesome_sharp, color: Colors.white),
          label: Text('Generate', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 213, 146, 39),
            minimumSize: Size(150, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0),
          ),
          onPressed: () {},
        ),
        const SizedBox(height: 20.0),
        _ImageArea(key: _imageAreaKey),
        const SizedBox(height: 20.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 231, 231, 231),
            backgroundColor: Color.fromARGB(255, 249, 178, 63),
            minimumSize: Size(150, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0),
          ),
          onPressed: () async {
            final imageData = _imageAreaKey.currentState?.imageData;
            if (imageData != null) {
              globalImageData = imageData;
              widget.addImageToProducts(imageData);
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
          child: const Text('Add to cart'),
        ),
        const SizedBox(height: 20.0),
        globalImageData != null
            ? Image.memory(globalImageData!, width: 200, height: 200)
            : const SizedBox.shrink(),
        const SizedBox(height: 25.0),
      ],
    );
  }

   Widget _model2UI() {
    return Column(
      children: <Widget>[
        PromptInput(),
        ElevatedButton.icon(
          icon: Icon(Icons.auto_awesome_sharp, color: Colors.white),
          label: Text('Generate', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 213, 146, 39),
            minimumSize: Size(150, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0),
          ),
          onPressed: () {},
        ),
        const SizedBox(height: 20.0),
        _ImageArea(key: _imageAreaKey),
        const SizedBox(height: 20.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 231, 231, 231),
            backgroundColor: Color.fromARGB(255, 249, 178, 63),
            minimumSize: Size(150, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0),
          ),
          onPressed: () async {
            final imageData = _imageAreaKey.currentState?.imageData;
            if (imageData != null) {
              globalImageData = imageData;
              widget.addImageToProducts(imageData);
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
          child: const Text('Add to cart'),
        ),
        const SizedBox(height: 20.0),
        globalImageData != null
            ? Image.memory(globalImageData!, width: 200, height: 200)
            : const SizedBox.shrink(),
        const SizedBox(height: 25.0),
      ],
    );
  }

   Widget _model3UI() {
    return Column(
      children: <Widget>[
        PromptInput(),
          ImageInput(
        onImagePicked: (imageData) {
          _imageAreaKey.currentState?.updateImageData(imageData);
        },
      ),
        ElevatedButton.icon(
          icon: Icon(Icons.auto_awesome_sharp, color: Colors.white),
          label: Text('Generate', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 213, 146, 39),
            minimumSize: Size(150, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0),
          ),
          onPressed: () {},
        ),
        const SizedBox(height: 20.0),
        _ImageArea(key: _imageAreaKey),
        const SizedBox(height: 20.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 231, 231, 231),
            backgroundColor: Color.fromARGB(255, 249, 178, 63),
            minimumSize: Size(150, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0),
          ),
          onPressed: () async {
            final imageData = _imageAreaKey.currentState?.imageData;
            if (imageData != null) {
              globalImageData = imageData;
              widget.addImageToProducts(imageData);
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
          child: const Text('Add to cart'),
        ),
        const SizedBox(height: 20.0),
        globalImageData != null
            ? Image.memory(globalImageData!, width: 200, height: 200)
            : const SizedBox.shrink(),
        const SizedBox(height: 25.0),
      ],
    );
  }
}

class ImageInput extends StatefulWidget {
  final Function(Uint8List) onImagePicked;

  const ImageInput({Key? key, required this.onImagePicked}) : super(key: key);

  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  Uint8List? _imageData;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final Uint8List imageData = await image.readAsBytes();
      setState(() {
        _imageData = imageData;
      });
      widget.onImagePicked(imageData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ElevatedButton.icon(
          icon: Icon(Icons.image, color: Colors.white),
          label: Text('Pick Image', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 213, 146, 39),
            minimumSize: Size(150, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0),
          ),
          onPressed: _pickImage,
        ),
        const SizedBox(height: 20.0),
        _imageData != null
            ? Image.memory(_imageData!, width: 200, height: 200)
            : Text(
                'No image selected',
                style: TextStyle(color: Colors.white),
              ),
      ],
    );
  }
}

class PromptInput extends StatefulWidget {
  @override
  _PromptInputState createState() => _PromptInputState();
}

class _PromptInputState extends State<PromptInput> {
  final TextEditingController _promptController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildInputField(
            controller: _promptController,
            hintText: 'Enter prompt',
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      width: 300,
      height: 40,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 1, 0, 0),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Color.fromARGB(255, 176, 167, 175), width: 1.0),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 10, 0, 0),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Color.fromARGB(255, 154, 139, 156), width: 1.0),
      ),
      child: imageData != null
          ? Image.memory(imageData!)
          : const Center(
              child: Text('Output Image', style: TextStyle(fontSize: 20.0),selectionColor: Color.fromARGB(255, 255, 255, 255),)),
    );
  }
}

class _PromptArea extends StatefulWidget {
  @override
  _PromptAreaState createState() => _PromptAreaState();
}

class _PromptAreaState extends State<_PromptArea> {
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _dressTypeController = TextEditingController();
  final TextEditingController _designController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildInputField(
            controller: _colorController,
            hintText: 'Color',
          ),
          const SizedBox(height: 15.0),
          _buildInputField(
            controller: _dressTypeController,
            hintText: 'Dress Type',
          ),
          const SizedBox(height: 15.0),
          _buildInputField(
            controller: _designController,
            hintText: 'Design',
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      width: 300,
      height: 40,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 1, 0, 0),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Color.fromARGB(255, 176, 167, 175), width: 1.0),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
      ),
    );
  }
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

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController _postController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: Column(
        children: [
          _buildPostInput(),
          Expanded(child: _buildPostList()),
        ],
      ),
    );
  }

  Widget _buildPostInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _postController,
              decoration: const InputDecoration(
                hintText: 'What\'s on your mind?',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _createPost,
          ),
        ],
      ),
    );
  }

  Future<void> _createPost() async {
    if (_postController.text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final newPost = Post(
        id: '',
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        content: _postController.text,
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('posts')
          .add(newPost.toFirestore());
      _postController.clear();
    }
  }

  Widget _buildPostList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts =
            snapshot.data!.docs.map((doc) => Post.fromFirestore(doc)).toList();

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return _buildPostItem(posts[index]);
          },
        );
      },
    );
  }

  Widget _buildPostItem(Post post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.userName, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4.0),
            Text(post.content),
            SizedBox(height: 8.0),
            _buildCommentSection(post),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection(Post post) {
    return Column(
      children: [
        _buildCommentInput(post),
        _buildCommentList(post),
      ],
    );
  }

  Widget _buildCommentInput(Post post) {
    final TextEditingController _commentController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _addComment(post, _commentController),
          ),
        ],
      ),
    );
  }

  Future<void> _addComment(Post post, TextEditingController controller) async {
    if (controller.text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final newComment = Comment(
        id: '',
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        content: controller.text,
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(post.id)
          .collection('comments')
          .add(newComment.toFirestore());

      controller.clear();
    }
  }

  Widget _buildCommentList(Post post) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(post.id)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final comments = snapshot.data!.docs
            .map((doc) => Comment.fromFirestore(doc))
            .toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            return _buildCommentItem(comments[index]);
          },
        );
      },
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          CircleAvatar(child: Text(comment.userName[0])),
          SizedBox(width: 8.0),
          Expanded(child: Text(comment.content)),
        ],
      ),
    );
  }
}
