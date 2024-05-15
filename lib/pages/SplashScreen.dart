import 'package:flutter/material.dart';
import 'package:part3/pages/ClothingHomePage.dart';
import 'package:part3/pages/LoginScreen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Simulate checking authentication status
    bool isAuthenticated = false; // Replace with your authentication logic

    Future.delayed(Duration(seconds: 2), () {
      // Navigate to either login or home page based on authentication status
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) =>
            isAuthenticated ? ClothingHomePage() : LoginScreen(),
      ));
    });

    return Scaffold(
      body: Center(
        child: FlutterLogo(size: 200),
      ),
    );
  }
}
