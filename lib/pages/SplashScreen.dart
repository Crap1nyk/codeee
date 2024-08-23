import 'package:flutter/material.dart';
import 'package:part3/pages/ClothingHomePage.dart';
import 'package:part3/pages/LoginScreen.dart';
import 'package:lottie/lottie.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool isAuthenticated = false; // Replace with your authentication logic
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _animation = ColorTween(
      begin: Colors.black,
      end: Color.fromARGB(255, 214, 55, 219),
    ).animate(_controller);

    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) =>
            isAuthenticated ? ClothingHomePage() : LoginScreen(),
      ));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient layer
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_animation.value!, Colors.black],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Lottie.asset(
                    'assets/images/Animation - 1724269845344 (3).json', 
                    width: 200,
                    height: 200,
                  ),
                ),
              );
            },
          ),
          // Logo image layer
          Center(
            child: Image.asset(
              'assets/images/ic_launcher.png', // Replace with your image path
              width: 200, // Adjust the size as needed
              height: 200,
            ),
          ),
        ],
      ),
    );
  }
}
