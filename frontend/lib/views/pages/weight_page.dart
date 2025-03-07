import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:frontend/data/colors.dart';
import 'name_page.dart';

class WeightPage extends StatefulWidget {
  @override
  _WeightPageState createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  double _currentWeight = 62; // Default weight
  bool isKg = true; // Default unit

  // Function to save weight to Firebase
  Future<void> _saveWeightToFirebase() async {
    try {
      User? user = FirebaseAuth.instance.currentUser; // Get logged-in user
      if (user != null) {
        Map<String, dynamic> data = {
          'weight': _currentWeight,
          'unit': isKg ? 'Kg' : 'Lbs',
        };

        print("Saving to Firestore: $data"); // Debug print

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(data, SetOptions(merge: true));

        print("Weight saved successfully!");
      } else {
        print("No user signed in!");
      }
    } catch (e) {
      print("Error saving weight: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor, // Use primaryColor
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    "2 of 8",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text(
              "What’s your current\nweight right now?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 70),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => isKg = true),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 35),
                    decoration: BoxDecoration(
                      color: isKg ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Kg",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isKg ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                GestureDetector(
                  onTap: () => setState(() => isKg = false),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 35),
                    decoration: BoxDecoration(
                      color: !isKg ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Lbs",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: !isKg ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Text(
              "${_currentWeight.round()} ${isKg ? "Kg" : "Lbs"}",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 50),
            Expanded(
              child: Center(
                child: Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 91, // Weights from 30 to 120
                    itemBuilder: (context, index) {
                      int weight = 30 + index;
                      double scale =
                          (weight == _currentWeight.round()) ? 1.5 : 1.0;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentWeight = weight.toDouble();
                            print(
                                "Updated weight: $_currentWeight"); // Debug print
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 150),
                          width: scale * 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: weight == _currentWeight.round()
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2,
                              ),
                              bottom: BorderSide(
                                color: weight == _currentWeight.round()
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            "$weight",
                            style: TextStyle(
                              fontSize: scale * 24,
                              fontWeight: FontWeight.bold,
                              color: weight == _currentWeight.round()
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: GestureDetector(
                onTap: () async {
                  print(
                      "Current weight before saving: $_currentWeight"); // Debug print
                  await _saveWeightToFirebase();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NamePage()),
                  );
                },
                child: Container(
                  width: 280,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
