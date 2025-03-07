import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrendingPage extends StatefulWidget {
  @override
  _TrendingPageState createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  Map<String, dynamic>? userInfo;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          userInfo = userDoc.data() as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trending Page")),
      body: userInfo == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name: ${userInfo!['name'] ?? 'N/A'}"),
                  Text("Weight: ${userInfo!['weight'] ?? 'N/A'}"),
                  Text("Gender: ${userInfo!['gender'] ?? 'N/A'}"),
                  Text(
                      "Chronic Illness: ${userInfo!['chronic_conditions'] ?? 'N/A'}"),
                  Text("Allergies: ${userInfo!['allergies'] ?? 'N/A'}"),
                  Text(
                      "Food Sensitivities: ${userInfo!['food_triggers'] ?? 'N/A'}"),
                  Text(
                      "Food Consumption: ${userInfo!['dietary_preferences'] ?? 'N/A'}"),
                  SizedBox(height: 20),
                  Text(
                    "Trending News, Recipes, or Food Alerts:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Add your logic to display trending news, recipes, or food alerts here
                ],
              ),
            ),
    );
  }
}
