import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'weight.dart';
void main() {
  runApp(AgePickerApp());
}

class AgePickerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AgeSelectionScreen(),
    );
  }
}

class AgeSelectionScreen extends StatefulWidget {
  @override
  _AgeSelectionScreenState createState() => _AgeSelectionScreenState();
}

class _AgeSelectionScreenState extends State<AgeSelectionScreen> {
  int _currentAge = 19;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("What’s your Age?", 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            ),
            SizedBox(height: 20),
            NumberPicker(
              value: _currentAge,
              minValue: 1,
              maxValue: 120,
              selectedTextStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.lightGreen),
              textStyle: TextStyle(fontSize: 22, color: Colors.grey),
              onChanged: (value) => setState(() => _currentAge = value),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print("Selected Age: $_currentAge");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeightSelectionScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: Text("Continue", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                print("Skipped");
              },
              child: Text("Skip", style: TextStyle(fontSize: 16, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
