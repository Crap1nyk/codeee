import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateofbirth = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController =
      TextEditingController(); // Added for Date of Birth

  Future<void> _signup() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      String uid = FirebaseAuth.instance.currentUser!.uid;

      print('User signed up: $uid');

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'phone': _phoneNumberController.text.trim(),
        'dob': _dateofbirth.text.trim(),
        'email':
            _emailController.text.trim(), // Assuming you collect this somewhere
        'gender': _genderController.text.trim(),
      }).then((_) {
        print("User information added to Firestore successfully");
        // Navigate to next screen or show success message
      }).catchError((error) {
        print("Failed to add user: $error");
        // Handle errors, e.g., show an error message
      });

      // User is signed up
      // Navigate to another screen, or do something else
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),

              TextField(
                controller: _genderController,
                decoration: InputDecoration(
                  labelText: 'Gender',
                ),
              ),

              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                ),
              ),

              TextField(
                controller: _dateofbirth,
                decoration: InputDecoration(
                  labelText: 'DOB',
                ),
              ),
              // Add a signup button that calls the _signup method when pressed
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signup,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
