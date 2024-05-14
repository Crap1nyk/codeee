import 'package:flutter/material.dart';
import 'package:part3/pages/ClothingHomePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:part3/pages/LoginScreen.dart';
import 'package:part3/pages/SplashScreen.dart';
import 'package:part3/pages/SignupScreen.dart';

void main() async {
  // Ensure that Firebase is initialized
  WidgetsFlutterBinding.ensureInitialized();
  // try {
  //   await Firebase.initializeApp();
  //   print('Firebase initialized successfully');
  // } catch (e) {
  //   print('Failed to initialize Firebase: $e');
  // }
  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
