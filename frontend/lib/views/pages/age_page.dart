import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'weight_page.dart';

class AgePage extends StatefulWidget {
  @override
  _AgePageState createState() => _AgePageState();
}

class _AgePageState extends State<AgePage> {
  int _currentAge = 19;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    "1 of 4",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Age Selection Title
            Text(
              "What’s your Age?",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 30),

            // Larger Age Picker with a Green Centered Box
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Green Box Behind the Number
                    Container(
                      height: 90,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Color(0xFFCDE26E), // Green background
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    // Number Picker
                    NumberPicker(
                      value: _currentAge,
                      minValue: 1,
                      maxValue: 100,
                      selectedTextStyle: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // White text on green
                      ),
                      textStyle: TextStyle(
                        fontSize: 30,
                        color: Colors.grey,
                      ),
                      onChanged: (value) => setState(() => _currentAge = value),
                      itemHeight: 90, // Increased height for better visibility
                      decoration: BoxDecoration(),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Continue Button
            GestureDetector(
              onTap: () {
                print("Selected Age: $_currentAge");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeightPage()),
                );
              },
              child: Container(
                width: 280,
                padding: EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Color(0xFFCDE26E),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
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
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.brightness_2, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),

            SizedBox(height: 45),
          ],
        ),
      ),
    );
  }
}
