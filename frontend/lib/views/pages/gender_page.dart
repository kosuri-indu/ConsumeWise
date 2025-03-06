import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/views/pages/home_page.dart';

class GenderPage extends StatefulWidget {
  @override
  _GenderPageState createState() => _GenderPageState();
}

class _GenderPageState extends State<GenderPage> {
  String? _selectedGender;

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  Future<void> _saveGenderToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && _selectedGender != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'gender': _selectedGender},
        SetOptions(merge: true),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
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
                Text("4 of 4",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          ),
          SizedBox(height: 140),
          Center(
            child: Column(
              children: [
                Text("What’s your gender?",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                GenderOption("Female", "assets/female.png",
                    _selectedGender == "Female", () => _selectGender("Female")),
                GenderOption("Male", "assets/male.png",
                    _selectedGender == "Male", () => _selectGender("Male")),
                GenderOption("Other", "assets/other.png",
                    _selectedGender == "Other", () => _selectGender("Other")),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color:
                        _selectedGender != null ? Colors.orange : Colors.grey,
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
                    onPressed:
                        _selectedGender != null ? _saveGenderToFirestore : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Finish",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.radio_button_checked, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🎯 Gender Option Widget
class GenderOption extends StatelessWidget {
  final String label;
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  GenderOption(this.label, this.iconPath, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 30),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.orange : Colors.grey),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.orange.withOpacity(0.2) : Colors.white,
        ),
        child: Row(
          children: [
            Image.asset(iconPath, width: 40, height: 40),
            SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 18)),
            Spacer(),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? Colors.orange : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
