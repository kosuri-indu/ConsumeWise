import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/data/colors.dart';
import 'package:frontend/views/pages/gender_page.dart';

class NamePage extends StatefulWidget {
  @override
  _NamePageState createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  TextEditingController _nameController = TextEditingController();

  Future<void> _saveNameToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser; // Get logged-in user
    if (user != null && _nameController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'name': _nameController.text},
        SetOptions(merge: true), // Merge in case the user doc exists
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GenderPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text("3 of 8",
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
                SizedBox(height: 40),
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 120),
                      Image.asset('assets/name.png', height: 180),
                      SizedBox(height: 100),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: "Your Name",
                            labelStyle: TextStyle(color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: secondaryColor),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _saveNameToFirestore,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 60, vertical: 14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Continue",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
