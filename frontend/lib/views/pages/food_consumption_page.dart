import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/data/colors.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodConsumptionPage extends StatefulWidget {
  @override
  _FoodConsumptionPageState createState() => _FoodConsumptionPageState();
}

class _FoodConsumptionPageState extends State<FoodConsumptionPage> {
  List<String> selectedDiets = [];

  final List<String> diets = [
    "Vegetarian",
    "Vegan",
    "Pescatarian",
    "Keto",
    "Paleo",
    "Mediterranean",
    "Low-Carb",
    "High-Protein",
    "Intermittent Fasting",
    "DASH Diet",
  ];

  void toggleSelection(String diet) {
    setState(() {
      if (selectedDiets.contains(diet)) {
        selectedDiets.remove(diet);
      } else {
        selectedDiets.add(diet);
      }
    });
  }

  Future<void> saveDietsToFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'dietary_preferences': selectedDiets,
      }, SetOptions(merge: true));

      // Redirect to HomePage after saving
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
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
                Text("8 of 8",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          ),
          SizedBox(height: 50),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("Select your dietary preferences",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ),
          SizedBox(height: 30),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: diets.map((diet) {
                  bool isSelected = selectedDiets.contains(diet);
                  return GestureDetector(
                    onTap: () => toggleSelection(diet),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.white,
                        border: Border.all(
                          color: isSelected ? primaryColor : Colors.black,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        diet,
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: selectedDiets.isNotEmpty ? primaryColor : Colors.grey,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextButton(
              onPressed: selectedDiets.isNotEmpty ? saveDietsToFirebase : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Finish",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.check, color: Colors.white),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
