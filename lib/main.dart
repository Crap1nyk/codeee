import 'package:flutter/material.dart';
import 'package:part3/pages/ClothingHomePage.dart';
import 'package:part3/pages/LoginScreen.dart';
import 'package:part3/pages/SplashScreen.dart';
import 'package:part3/pages/SignupScreen.dart';


void main() {
  runApp(ClothingApp());
}

class ClothingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clothing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Define initial route as Splash screen
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(), // Define route for SplashScreen
        '/login': (context) => LoginScreen(), // Define route for LoginScreen
        '/home': (context) => ClothingHomePage(), // Define route for ClothingHomePage
        '/signup': (context) => SignupScreen(), 
      },
    );
  }
}
