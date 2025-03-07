import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_consumption_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodSensitivePage extends StatefulWidget {
  @override
  _FoodSensitivePageState createState() => _FoodSensitivePageState();
}

class _FoodSensitivePageState extends State<FoodSensitivePage> {
  List<String> selectedTriggers = [];
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance

  final List<String> triggers = [
    "Spicy Foods 🌶️",
    "Caffeine ☕",
    "Alcohol 🍷",
    "Dairy 🥛",
    "Processed Foods 🍔",
    "Artificial Sweeteners 🍬",
    "Citrus Fruits 🍊",
    "Gluten 🌾",
    "Fried Foods 🍟",
    "High-Fat Foods 🥩",
  ];

  void _saveDataToFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'triggers': selectedTriggers,
      }, SetOptions(merge: true));
    } else {
      print("Error: No authenticated user found.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 50),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                Text("3 of 4",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          ),
          SizedBox(height: 50),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Trigger Ingredients & Food Sensitivities",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: triggers.map((trigger) {
                  bool isSelected = selectedTriggers.contains(trigger);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelected
                            ? selectedTriggers.remove(trigger)
                            : selectedTriggers.add(trigger);
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.orange.shade100 : Colors.white,
                        border: Border.all(
                            color: isSelected ? Colors.orange : Colors.grey,
                            width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(trigger,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: selectedTriggers.isNotEmpty
                ? () {
                    _saveDataToFirebase();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FoodConsumptionPage(),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
            child: Text(
              "Next",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
