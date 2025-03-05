import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'name_page.dart';

class WeightPage extends StatefulWidget {
  @override
  _WeightPageState createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  int _currentWeight = 60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("What’s your Weight?", 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            ),
            SizedBox(height: 20),
            NumberPicker(
              value: _currentWeight,
              minValue: 30,
              maxValue: 120,
              selectedTextStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
              textStyle: TextStyle(fontSize: 22, color: Colors.grey),
              onChanged: (value) => setState(() => _currentWeight = value),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NamePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: Text("Continue", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}