import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/data/colors.dart';
import 'food_sensitive_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllergiesPage extends StatefulWidget {
  @override
  _AllergiesPageState createState() => _AllergiesPageState();
}

class _AllergiesPageState extends State<AllergiesPage> {
  List<String> selectedAllergies = [];

  final List<String> allergies = [
    "Peanuts",
    "Nuts",
    "Milk",
    "Eggs",
    "Fish",
    "Shellfish",
    "Soy",
    "Wheat",
    "Sesame",
    "Mustard",
    "None",
  ];

  void saveToFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'allergies': selectedAllergies,
      }, SetOptions(merge: true));

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FoodSensitivePage()),
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
                Text("6 of 8",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          ),
          SizedBox(height: 50),
          Text("Select your allergies",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          SizedBox(height: 30),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: allergies.map((allergy) {
                  bool isSelected = selectedAllergies.contains(allergy);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelected
                            ? selectedAllergies.remove(allergy)
                            : selectedAllergies.add(allergy);
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.white,
                        border: Border.all(
                            color: isSelected ? primaryColor : Colors.black,
                            width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(allergy,
                          style: TextStyle(
                              fontSize: 16,
                              color: isSelected ? Colors.white : Colors.black)),
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
              color: selectedAllergies.isNotEmpty ? primaryColor : Colors.grey,
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
              onPressed: selectedAllergies.isNotEmpty ? saveToFirebase : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Next",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, color: Colors.white),
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
