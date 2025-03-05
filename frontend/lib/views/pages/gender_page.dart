import 'package:flutter/material.dart';
import 'package:frontend/views/pages/profile_page.dart';
// 🎯 Gender Selection Page
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("What’s your gender?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            ),
            SizedBox(height: 20),
            GenderOption("Female", "assets/female.png", _selectedGender == "Female", () => _selectGender("Female")),
            GenderOption("Male", "assets/male.png", _selectedGender == "Male", () => _selectGender("Male")),
            GenderOption("Other", "assets/other.png", _selectedGender == "Other", () => _selectGender("Other")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedGender != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: Text("Finish", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
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
            if (isSelected)
              Icon(Icons.radio_button_checked, color: Colors.orange)
            else
              Icon(Icons.radio_button_unchecked, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
