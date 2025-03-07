import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/data/colors.dart';
import 'allergies_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChronicPage extends StatefulWidget {
  @override
  _ChronicPageState createState() => _ChronicPageState();
}

class _ChronicPageState extends State<ChronicPage> {
  List<String> conditions = [
    "Diabetes",
    "Hypertension",
    "High Cholesterol",
    "PCOS/PCOD",
    "Celiac Disease",
    "Lactose Intolerance",
    "IBS",
    "Kidney Disease",
    "Thyroid Disorders",
    "GERD",
    "Autoimmune Disorders"
  ];

  List<String> selectedConditions = [];

  void toggleSelection(String condition) {
    setState(() {
      if (selectedConditions.contains(condition)) {
        selectedConditions.remove(condition);
      } else {
        selectedConditions.add(condition);
      }
    });
  }

  Future<void> saveToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'chronic_conditions': selectedConditions,
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
                Text("5 of 8",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          ),
          SizedBox(height: 50),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Select your chronic conditions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: conditions.map((condition) {
                  bool isSelected = selectedConditions.contains(condition);
                  return GestureDetector(
                    onTap: () => toggleSelection(condition),
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
                        condition,
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
              color: selectedConditions.isNotEmpty ? primaryColor : Colors.grey,
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
              onPressed: selectedConditions.isNotEmpty
                  ? () async {
                      await saveToFirestore();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AllergiesPage()),
                      );
                    }
                  : null,
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
