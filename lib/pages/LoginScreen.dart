import 'package:flutter/material.dart';
import 'package:part3/pages/ClothingHomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print("User logged in");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ClothingHomePage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Unknown error occurred')),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    }
  }

  void _forgotPassword() {
    print("Forgot Password clicked");
    // Handle forgot password logic
  }

  void _loginWithGoogle() {
    print("Login with Google clicked");
    // Handle login with Google logic
  }

  void _loginWithFacebook() {
    print("Login with Facebook clicked");
    // Handle login with Facebook logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 50),
                  Image.asset(
                    'assets/images/logo.jpg', // Replace with your image asset path
                    height: 100,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Log In',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Montserrat', // Change to your preferred font
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Enter your details below to log in',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Montserrat', // Change to your preferred font
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: const Color.fromARGB(179, 0, 0, 0)),
                      filled: true,
                      fillColor: Color.fromARGB(255, 246, 245, 245),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: TextStyle(color: const Color.fromARGB(255, 6, 4, 4)),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: const Color.fromARGB(179, 0, 0, 0)),
                      filled: true,
                      fillColor: Color.fromARGB(255, 246, 245, 245),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: _forgotPassword,
                    child: Text(
                      'Forgot Password?',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromARGB(255, 180, 83, 180),
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onPressed: () => _login(context),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'or login with',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: _loginWithGoogle,
                        child: Image.asset(
                          'assets/images/google_logo.png', // Google logo asset path
                          height: 40,
                        ),
                      ),
                      SizedBox(width: 30),
                      GestureDetector(
                        onTap: _loginWithFacebook,
                        child: Image.asset(
                          'assets/images/facebook_logo.png', // Facebook logo asset path
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
