import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/data/colors.dart';
import 'package:numberpicker/numberpicker.dart';
import 'weight_page.dart';

class AgePage extends StatefulWidget {
  @override
  _AgePageState createState() => _AgePageState();
}

class _AgePageState extends State<AgePage> {
  int _currentAge = 19;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _saveAgeToFirestore() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set(
          {'age': _currentAge},
          SetOptions(merge: true),
        );
        print("Age saved: $_currentAge");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WeightPage()),
        );
      } catch (e) {
        print("Error saving age: $e");
      }
    } else {
      print("No user is signed in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "1 of 8",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Age Selection Title
            const Text(
              "What’s your Age?",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 30),

            // Larger Age Picker with a Green Centered Box
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Green Box Behind the Number
                    Container(
                      height: 90,
                      width: 150,
                      decoration: BoxDecoration(
                        color: primaryColor, // Green background
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    // Number Picker
                    NumberPicker(
                      value: _currentAge,
                      minValue: 1,
                      maxValue: 100,
                      selectedTextStyle: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text on green
                      ),
                      textStyle: const TextStyle(
                        fontSize: 30,
                        color: Colors.grey,
                      ),
                      onChanged: (value) => setState(() => _currentAge = value),
                      itemHeight: 90, // Increased height for better visibility
                      decoration: const BoxDecoration(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Continue Button
            GestureDetector(
              onTap: _saveAgeToFirestore,
              child: Container(
                width: 280,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 45),
          ],
        ),
      ),
    );
  }
}
