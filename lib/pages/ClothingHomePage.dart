import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not logged in');
        return;
      }

      String uid = user.uid;
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
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null)
              Image.file(_image!)
            else
              Text('No image selected.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Upload Image'),
            ),
          ],
        ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'), // Profile page app bar with title
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Rounded UI with user image and information
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[600],
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
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'Phone: ${userInfo['phone'] ?? 'Not specified'}',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'Wallet: \$${userInfo['walletAmount'] ?? 0}',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // List tiles for options
          _buildListTile(Icons.shopping_bag, 'My Orders', () {
            // Navigate to My Orders page
          }),
          _buildListTile(Icons.person, 'Personal Info', () {
            _showPersonalInfoDialog(context); // Show personal info dialog
          }),
          _buildListTile(Icons.help, 'FAQs', () {
            // Navigate to FAQs page
          }),
          _buildListTile(Icons.account_balance_wallet, 'Wallet', () {
            // Navigate to Wallet page
          }),
          _buildListTile(Icons.logout, 'Logout', () {
            FirebaseAuth.instance.signOut(); // Sign out current user
            // Navigate to Login page
          }),
        ],
      ),
    );
  }

  // Function to create list tiles
  ListTile _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: onTap,
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
