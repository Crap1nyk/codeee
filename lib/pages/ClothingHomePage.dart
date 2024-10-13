import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:part3/main.dart';
import 'package:part3/pages/LoginScreen.dart';

import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'product_page.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io'; // For File handling
import 'package:path/path.dart' as path;
import 'wallet_screen.dart';
import 'MyOrdersScreen.dart';

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
            width: 300,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/anime.jpeg'), // Replace with your section banner image
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
            width: 300,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/tradition.jpeg'), // Replace with your section banner image
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

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late User user;
  Map<String, dynamic> userInfo = {};
  File? _image;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    _fetchUserInfo();
  }

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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 0, 0),
            Color.fromARGB(255, 50, 50, 50)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Profile', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(208, 108, 236, 1),
                    Color.fromARGB(255, 89, 0, 255)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: const [
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
                      backgroundColor: Colors.grey[800],
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : (userInfo['photoUrl'] != null
                              ? NetworkImage(userInfo['photoUrl'])
                              : null) as ImageProvider?,
                      child: _image == null && userInfo['photoUrl'] == null
                          ? const Icon(Icons.camera_alt, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userInfo['name'] ?? 'Name not available',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Gender: ${userInfo['gender'] ?? 'Not specified'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Phone: ${userInfo['phone'] ?? 'Not specified'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Wallet: \$${userInfo['walletAmount'] ?? 0}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: const [
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyOrdersScreen()),
                    );
                  }),
                  _buildListTile(CupertinoIcons.person_fill, 'Personal Info',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalInfoScreen(
                          userInfo: userInfo,
                          user: user,
                        ),
                      ),
                    );
                  }),
                  _buildListTile(CupertinoIcons.question_circle_fill, 'FAQs',
                      () {
                    // Navigate to FAQs page
                  }),
                  _buildListTile(CupertinoIcons.money_dollar_circle, 'Wallet',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WalletScreen()),
                    );
                  }),
                  _buildListTile(
                      CupertinoIcons.arrow_right_circle_fill, 'Logout', () {
                    FirebaseAuth.instance.signOut();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      leading: Icon(icon, color: Colors.white),
      onTap: onTap,
      tileColor: Colors.black,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white24, width: 1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    );
  }
}

class PersonalInfoScreen extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  final User user;

  const PersonalInfoScreen(
      {required this.userInfo, required this.user, Key? key})
      : super(key: key);

  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> userInfo;

  @override
  void initState() {
    super.initState();
    userInfo = Map<String, dynamic>.from(widget.userInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Personal Info',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: userInfo['name'],
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purpleAccent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onSaved: (value) {
                  userInfo['name'] = value!;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: userInfo['gender'],
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purpleAccent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onSaved: (value) {
                  userInfo['gender'] = value!;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: userInfo['dob'],
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purpleAccent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onSaved: (value) {
                  userInfo['dob'] = value!;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: userInfo['address'],
                decoration: const InputDecoration(
                  labelText: 'Address',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purpleAccent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onSaved: (value) {
                  userInfo['address'] = value!;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: userInfo['pincode'],
                decoration: const InputDecoration(
                  labelText: 'Pincode',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purpleAccent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  userInfo['pincode'] = value!;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: userInfo['district'],
                decoration: const InputDecoration(
                  labelText: 'District',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purpleAccent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onSaved: (value) {
                  userInfo['district'] = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _savePersonalInfo();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                ),
                child:
                    const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePersonalInfo() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(widget.user.uid).update(userInfo);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal info updated successfully')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update personal info: $e')),
      );
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Cart',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('products')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(color: Colors.redAccent),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final cart =
              snapshot.data?.docs.map((doc) => doc.data()).toList() ?? [];

          return cart.isEmpty
              ? const Center(
                  child: Text(
                    'Your cart is empty',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: cart.length,
                  itemBuilder: (context, index) {
                    final item = cart[index] as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Card(
                        color: Colors.grey[850],
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(20.0),
                          leading: item['image'] is List
                              ? Image.memory(
                                  Uint8List.fromList(
                                      (item['image'] as List).cast<int>()),
                                  width: 100,
                                  height: 100,
                                )
                              : null,
                          title: Text(
                            item['name'].toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '\$${item['price'].toString()}',
                            style: const TextStyle(color: Colors.greenAccent),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductPage(
                                    product: item,
                                    productId: Uuid().v4(),
                                    productName: "T-shirt",
                                    productPrice: "550"),
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
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.greenAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  // Add your checkout logic here
                },
                child: const Text(
                  'Checkout',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
    );
  }
}

final GlobalKey<_ImageAreaState> _imageAreaKey = GlobalKey();
final GlobalKey<_PromptAreaState> _promptAreaKey = GlobalKey();

class ProfileScreen extends StatefulWidget {
  final Function(Uint8List) addImageToProducts;

  const ProfileScreen({Key? key, required this.addImageToProducts})
      : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedModel = 'Model 1';
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
                  items: <String>['Model 1', 'Model 2', 'Model 3']
                      .map((String value) {
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
                _selectedModel == 'Model 1'
                    ? _model1UI()
                    : (_selectedModel == 'Model 2' ? _model2UI() : _model3UI()),
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
        _PromptArea(key: _promptAreaKey),
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
          onPressed: () async {
            final inputValues = _promptAreaKey.currentState?.getInputValues();
            if (inputValues != null) {
              _generateImage(inputValues);
            }
          },
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

  Future<void> _generateImage(Map<String, String> inputValues) async {
    final color = inputValues['color'];
    final dressType = inputValues['dressType'];
    final design = inputValues['design'];

    final url = Uri.parse('https://fragger246-mockupgen.hf.space/call/infer');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "data": [
          'single',
          color,
          dressType,
          design,
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
        print("Unexpected response format: ${response.body}");
      }
    } else {
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
                            _imageAreaKey.currentState
                                ?.updateImageData(imageResponse.bodyBytes);
                            resultReady = true;
                          });
                        } else {
                          print(
                              "Failed to download image: ${imageResponse.body}");

                          resultReady = true;
                        }
                      } else {
                        print("No valid data found.");

                        resultReady = true;
                      }
                    } else {
                      print("Data is empty or 'null'.");

                      resultReady = true;
                    }
                  } catch (e) {
                    print("Error parsing JSON data: $e");
                    print("Response body: ${dataLine}");

                    resultReady = true;
                  }
                } else {
                  print("Data line is empty.");

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
        print("Failed to retrieve result: ${response.body}");
        resultReady = true;
      }
    }
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
        border:
            Border.all(color: Color.fromARGB(255, 176, 167, 175), width: 1.0),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
// class _PromptArea extends StatefulWidget {
//   const _PromptArea{Key? key}) : super(key: key);

//   @override
//   _PromptAreaState createState() => _PromptAreaState();
// }

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
        border:
            Border.all(color: Color.fromARGB(255, 154, 139, 156), width: 1.0),
      ),
      child: imageData != null
          ? Image.memory(imageData!)
          : const Center(
              child: Text(
              'Output Image',
              style: TextStyle(fontSize: 20.0),
              selectionColor: Color.fromARGB(255, 255, 255, 255),
            )),
    );
  }
}

class _PromptArea extends StatefulWidget {
  const _PromptArea({Key? key}) : super(key: key);

  @override
  _PromptAreaState createState() => _PromptAreaState();
}

class _PromptAreaState extends State<_PromptArea> {
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _dressTypeController = TextEditingController();
  final TextEditingController _designController = TextEditingController();

  Map<String, String> getInputValues() {
    return {
      'color': _colorController.text,
      'dressType': _dressTypeController.text,
      'design': _designController.text,
    };
  }

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
        border:
            Border.all(color: Color.fromARGB(255, 176, 167, 175), width: 1.0),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
  const CommunityPage({Key? key}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController _captionController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPost(BuildContext context) async {
    if (_selectedImage == null || _captionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image and caption are required')),
      );
      return;
    }

    String fileName = path.basename(_selectedImage!.path);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final postId = FirebaseFirestore.instance.collection('posts').doc().id;
      final storageRef =
          FirebaseStorage.instance.ref().child('posts/$uid/$postId/$fileName');

      final uploadTask = storageRef.putFile(_selectedImage!);

      await uploadTask.whenComplete(() => null);

      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('posts').doc(postId).set({
        'uid': uid,
        'downloadUrl': downloadUrl,
        'caption': _captionController.text,
        'likes': 0,
        'dislikes': 0,
        'comments': [],
        'likedBy': [],
        'dislikedBy': [],
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _selectedImage = null;
        _captionController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post uploaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _captionController,
                  decoration: InputDecoration(
                    labelText: 'What\'s on your mind?',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.image, color: Colors.white),
                      onPressed: _pickImage,
                    ),
                  ),
                  maxLines: 3,
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 10),
                _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        height: 70,
                        width: 50,
                        fit: BoxFit.contain,
                      )
                    : Container(),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _uploadPost(context),
                  child: Text('Post'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: PostsList()),
        ],
      ),
    );
  }
}

class PostsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<Post> posts = snapshot.data!.docs
            .map((doc) => Post.fromDocumentSnapshot(doc))
            .toList();

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostItem(post: posts[index]);
          },
        );
      },
    );
  }
}

class PostItem extends StatefulWidget {
  final Post post;

  PostItem({required this.post});

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  bool _showComments = false;
  final TextEditingController _commentController = TextEditingController();

  void _likePost() {
    if (!widget.post.likedBy.contains(userId)) {
      FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .update({
        'likes': widget.post.likes + 1,
        'likedBy': FieldValue.arrayUnion([userId]),
        'dislikedBy': FieldValue.arrayRemove([userId]),
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have already liked this post')),
      );
    }
  }

  void _dislikePost() {
    if (!widget.post.dislikedBy.contains(userId)) {
      FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .update({
        'dislikes': widget.post.dislikes + 1,
        'dislikedBy': FieldValue.arrayUnion([userId]),
        'likedBy': FieldValue.arrayRemove([userId]),
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have already disliked this post')),
      );
    }
  }

  void _toggleComments() {
    setState(() {
      _showComments = !_showComments;
    });
  }

  void _addComment(String comment) async {
    if (comment.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .update({
        'comments': FieldValue.arrayUnion([
          {
            'comment': comment,
            'userId': user.uid,
            'userName': user.displayName ?? 'Anonymous',
          }
        ]),
      });

      _commentController.clear();
    }
  }

  void _deletePost() async {
    if (widget.post.uid == userId) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You cannot delete this post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 20,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.userName ?? 'Unknown User',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.post.userEmail ?? 'No Email',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: 400, maxWidth: 400), // Limit the height of the image
            child: Image.network(
              widget.post.downloadUrl,
              width: 400,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.post.caption,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.thumb_up, color: Colors.white),
                onPressed: _likePost,
              ),
              Text(widget.post.likes.toString(),
                  style: TextStyle(color: Colors.white)),
              IconButton(
                icon: Icon(Icons.thumb_down, color: Colors.white),
                onPressed: _dislikePost,
              ),
              Text(widget.post.dislikes.toString(),
                  style: TextStyle(color: Colors.white)),
              IconButton(
                icon: Icon(Icons.comment, color: Colors.white),
                onPressed: _toggleComments,
              ),
              Text(widget.post.comments.length.toString(),
                  style: TextStyle(color: Colors.white)),
            ],
          ),
          if (_showComments)
            Column(
              children: widget.post.comments.map((comment) {
                return ListTile(
                  title: Text(comment['userName'] ?? 'Anonymous',
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text(comment['comment'] ?? '',
                      style: TextStyle(color: Colors.white70)),
                );
              }).toList()
                ..add(
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        labelText: 'Add a comment',
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      onSubmitted: _addComment,
                    ),
                  ) as ListTile,
                ),
            ),
          if (widget.post.uid == userId)
            TextButton(
              onPressed: _deletePost,
              child: Text('Delete Post', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}

class Post {
  final String id;
  final String uid;
  final String downloadUrl;
  final String caption;
  final int likes;
  final int dislikes;
  final List<dynamic> comments;
  final List<dynamic> likedBy;
  final List<dynamic> dislikedBy;
  final String? userName; // Added field
  final String? userEmail; // Added field

  Post({
    required this.id,
    required this.uid,
    required this.downloadUrl,
    required this.caption,
    required this.likes,
    required this.dislikes,
    required this.comments,
    required this.likedBy,
    required this.dislikedBy,
    this.userName,
    this.userEmail,
  });

  factory Post.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Post(
      id: doc.id,
      uid: data['uid'] as String? ?? '',
      downloadUrl: data['downloadUrl'] as String? ?? '',
      caption: data['caption'] as String? ?? '',
      likes: (data['likes'] as int?) ?? 0,
      dislikes: (data['dislikes'] as int?) ?? 0,
      comments: List<dynamic>.from(data['comments'] ?? []),
      likedBy: List<dynamic>.from(data['likedBy'] ?? []),
      dislikedBy: List<dynamic>.from(data['dislikedBy'] ?? []),
      userName: data['userName'] as String?,
      userEmail: data['userEmail'] as String?,
    );
  }
}
