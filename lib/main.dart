import 'package:flutter/material.dart';
import 'package:part3/pages/root.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:part3/pages/SignupScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: MainHomePage(),
      // debugShowCheckedModeBanner: false,
      // home: Home(),
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pages Example'),
      ),
      body: Column(
        children: [
          // Expanded(child: ClothingHomePage()),
          // Expanded(child: LoginScreen()),
          Expanded(child: SignupScreen()),
        ],
      ),
    );
  }
}

class MainHomePage extends StatelessWidget {
  const MainHomePage({Key? key}) : super(key: key);

  Future<void> _uploadImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected')),
      );
      return;
    }

    File file = File(pickedFile.path);
    String fileName = path.basename(file.path);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final postId = FirebaseFirestore.instance.collection('posts').doc().id;
      final storageRef =
          FirebaseStorage.instance.ref().child('posts/$uid/$postId/$fileName');

      final uploadTask = storageRef.putFile(file);

      await uploadTask.whenComplete(() => null);

      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('posts').doc(postId).set({
        'uid': uid,
        'downloadUrl': downloadUrl,
        'likes': 0,
        'dislikes': 0,
        'comments': [],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Main Home Page')), // Home page app bar with title
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => _uploadImage(context),
            child: Text('Upload Image'),
          ),
          Expanded(child: PostsList()), // Display posts
        ],
      ),
    );
  }
}

class PostsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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

class Post {
  final String id;
  final String uid;
  final String downloadUrl;
  final int likes;
  final int dislikes;
  final List<String> comments;

  Post({
    required this.id,
    required this.uid,
    required this.downloadUrl,
    required this.likes,
    required this.dislikes,
    required this.comments,
  });

  factory Post.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Post(
      id: doc.id,
      uid: data['uid'] ?? '',
      downloadUrl: data['downloadUrl'] ?? '',
      likes: data['likes'] ?? 0,
      dislikes: data['dislikes'] ?? 0,
      comments: List<String>.from(data['comments'] ?? []),
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
  void _likePost() {
    FirebaseFirestore.instance.collection('posts').doc(widget.post.id).update({
      'likes': widget.post.likes + 1,
    });
  }

  void _dislikePost() {
    FirebaseFirestore.instance.collection('posts').doc(widget.post.id).update({
      'dislikes': widget.post.dislikes + 1,
    });
  }

  void _addComment(String comment) {
    FirebaseFirestore.instance.collection('posts').doc(widget.post.id).update({
      'comments': FieldValue.arrayUnion([comment]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          Image.network(widget.post.downloadUrl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.thumb_up),
                onPressed: _likePost,
              ),
              Text(widget.post.likes.toString()),
              IconButton(
                icon: Icon(Icons.thumb_down),
                onPressed: _dislikePost,
              ),
              Text(widget.post.dislikes.toString()),
            ],
          ),
          Column(
            children:
                widget.post.comments.map((comment) => Text(comment)).toList(),
          ),
          TextField(
            onSubmitted: (value) {
              _addComment(value);
            },
            decoration: InputDecoration(
              labelText: 'Add a comment',
            ),
          ),
        ],
      ),
    );
  }
}
