import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
      home: AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return LoginScreen();
          } else {
            return MainHomePage();
          }
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  void _signUp() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _login,
                  child: Text('Login'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _signUp,
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
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
        title: const Text('Main Home Page'),
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
          ElevatedButton(
            onPressed: () => _uploadImage(context),
            child: Text('Upload Image'),
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
              IconButton(
                icon: Icon(Icons.comment),
                onPressed: _toggleComments,
              ),
            ],
          ),
          _showComments
              ? Column(
                  children: [
                    ...widget.post.comments.map((comment) {
                      return ListTile(
                        title: Text(comment['userName']),
                        subtitle: Text(comment['comment']),
                      );
                    }).toList(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                labelText: 'Add a comment',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () =>
                                _addComment(_commentController.text),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}

class Post {
  final String id;
  final String uid;
  final String downloadUrl;
  final int likes;
  final int dislikes;
  final List<Map<String, dynamic>> comments;
  final List<String> likedBy;
  final List<String> dislikedBy;

  Post({
    required this.id,
    required this.uid,
    required this.downloadUrl,
    required this.likes,
    required this.dislikes,
    required this.comments,
    required this.likedBy,
    required this.dislikedBy,
  });

  factory Post.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Post(
      id: doc.id,
      uid: data['uid'] ?? '',
      downloadUrl: data['downloadUrl'] ?? '',
      likes: data['likes'] ?? 0,
      dislikes: data['dislikes'] ?? 0,
      comments: List<Map<String, dynamic>>.from(data['comments'] ?? []),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      dislikedBy: List<String>.from(data['dislikedBy'] ?? []),
    );
  }
}
