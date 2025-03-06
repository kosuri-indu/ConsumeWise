import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AboutMePage extends StatefulWidget {
  final String name;
  final String age;
  final String gender;
  final String weight;

  AboutMePage({
    required this.name,
    required this.age,
    required this.gender,
    required this.weight,
  });

  @override
  _AboutMePageState createState() => _AboutMePageState();
}

class _AboutMePageState extends State<AboutMePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  String selectedGender = "Select Gender";
  String selectedUnit = "Kg"; // Default unit

  @override
  void initState() {
    super.initState();
    nameController.text = widget.name;
    ageController.text = widget.age;

    // Extract weight value and unit
    List<String> weightParts = widget.weight.split(" ");
    weightController.text = weightParts.isNotEmpty ? weightParts[0] : "";
    selectedUnit = weightParts.length > 1 ? weightParts[1] : "Kg";

    selectedGender = widget.gender != "N/A" ? widget.gender : "Select Gender";
  }

  void saveChanges() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': nameController.text.trim(),
        'age': int.tryParse(ageController.text.trim()) ?? 0,
        'gender': selectedGender,
        'weight': double.tryParse(weightController.text.trim()) ?? 0.0,
        'unit': selectedUnit,
      });

      Navigator.pop(context, {
        "name": nameController.text.trim(),
        "age": ageController.text.trim(),
        "gender": selectedGender,
        "weight": "${weightController.text.trim()} $selectedUnit"
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit About Me"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: nameController),

            SizedBox(height: 15),

            // Age Field
            Text("Age", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
                controller: ageController, keyboardType: TextInputType.number),

            SizedBox(height: 15),

            // Gender Dropdown
            Text("Gender", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedGender,
              items: ["Select Gender", "Male", "Female", "Other"]
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedGender = newValue!;
                });
              },
            ),

            SizedBox(height: 15),

            // Weight Field
            Text("Weight", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedUnit,
                  items: ["Kg", "Lbs"].map((String unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: (newUnit) {
                    setState(() {
                      selectedUnit = newUnit!;
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: 30),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: saveChanges,
                child: Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
