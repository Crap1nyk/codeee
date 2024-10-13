import 'package:flutter/material.dart';
import 'package:part3/pages/ClothingHomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:part3/pages/SignupScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Navigate to the home page if login is successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ClothingHomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  void _signUp() async {
    SignupScreen();
  }

  Future<void> _showForgotPasswordDialog(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: 'Enter your email address',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
              },
            ),
            TextButton(
              child: Text('Send'),
              onPressed: () async {
                String email = emailController.text.trim();
                if (email.isNotEmpty) {
                  try {
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email);
                    // Show a success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Password reset email sent.")),
                    );
                  } catch (e) {
                    // Show an error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text("Failed to send password reset email.")),
                    );
                  }
                }
                Navigator.of(dialogContext).pop(); // Dismiss dialog
              },
            ),
          ],
        );
      },
    );
  }

  final TextEditingController emailController = TextEditingController();

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
    // Obtain the height of the screen
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight, // Ensure the content takes full height
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 50),
                Image.asset(
                  'assets/images/logo.jpg', // Replace with your image asset path
                  height: 150,
                ),
                SizedBox(height: 30),
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
                    labelStyle:
                        TextStyle(color: const Color.fromARGB(179, 0, 0, 0)),
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
                    labelStyle:
                        TextStyle(color: const Color.fromARGB(179, 0, 0, 0)),
                    filled: true,
                    fillColor: Color.fromARGB(255, 246, 245, 245),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  obscureText: true,
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _showForgotPasswordDialog(context),
                  child: Text(
                    'Forgot Password?',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color.fromARGB(255, 216, 71, 209),
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
                SizedBox(height: 30),
                ElevatedButton(
                  child: Text(
                    'SignUp',
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
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SignupScreen()),
                    );
                  },
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
                        'assets/images/R.png', // Google logo asset path
                        height: 40,
                      ),
                    ),
                    SizedBox(width: 30),
                    GestureDetector(
                      onTap: _loginWithFacebook,
                      child: Image.asset(
                        'assets/images/facebook-logo-0.png', // Facebook logo asset path
                        height: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
