import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:frontend/views/pages/signin_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool aiRecommendations = true;
  String userName = "Loading...";
  String userAge = "";
  String userGender = "";
  String userWeight = "";
  List<String> chronicConditions = [];
  List<String> allergies = [];
  List<String> triggers = [];
  List<String> dietaryPreferences = [];

  final List<String> chronicConditionsList = [
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
  final List<String> allergiesList = [
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
  ];
  final List<String> triggersList = [
    "Spicy Foods",
    "Caffeine",
    "Alcohol",
    "Dairy",
    "Processed Foods",
    "Artificial Sweeteners",
    "Citrus Fruits",
    "Gluten",
    "Fried Foods",
    "High-Fat Foods",
  ];
  final List<String> dietaryPreferencesList = [
    "Vegetarian",
    "Vegan",
    "Pescatarian",
    "Keto",
    "Paleo",
    "Mediterranean",
    "Low-Carb",
    "High-Protein",
    "Intermittent Fasting",
    "DASH Diet",
  ];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? "Unknown";
          userAge = userDoc['age']?.toString() ?? "N/A";
          userGender = userDoc['gender'] ?? "N/A";
          String weightValue = userDoc['weight']?.toString() ?? "N/A";
          String unit = userDoc['unit'] ?? "";
          userWeight = unit.isNotEmpty ? "$weightValue $unit" : weightValue;
          chronicConditions =
              List<String>.from(userDoc['chronic_conditions'] ?? []);
          allergies = List<String>.from(userDoc['allergies'] ?? []);
          triggers = List<String>.from(userDoc['triggers'] ?? []);
          dietaryPreferences =
              List<String>.from(userDoc['dietary_preferences'] ?? []);
        });
      }
    }
  }

  void updateUserData(String field, dynamic newValue) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        field: newValue,
      });

      setState(() {
        if (field == "name") userName = newValue;
        if (field == "age") userAge = newValue;
        if (field == "gender") userGender = newValue;
        if (field == "weight") userWeight = newValue;
        if (field == "chronicConditions")
          chronicConditions = List<String>.from(newValue);
        if (field == "allergies") allergies = List<String>.from(newValue);
        if (field == "triggers") triggers = List<String>.from(newValue);
        if (field == "dietaryPreferences")
          dietaryPreferences = List<String>.from(newValue);
      });
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignInPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile.jpg'),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.edit, size: 18),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(userName,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(height: 30),
            sectionTitle("Personal Information"),
            profileOption(
                icon: Icons.person,
                title: "Name",
                value: userName,
                onEdit: (newValue) => updateUserData("name", newValue)),
            profileOption(
                icon: Icons.cake,
                title: "Age",
                value: userAge,
                onEdit: (newValue) => updateUserData("age", newValue)),
            profileOption(
                icon: Icons.male,
                title: "Gender",
                value: userGender,
                onEdit: (newValue) => updateUserData("gender", newValue)),
            profileOption(
                icon: Icons.monitor_weight,
                title: "Weight",
                value: userWeight,
                onEdit: (newValue) => updateUserData("weight", newValue)),
            sectionTitle("Health Details"),
            multiSelectOption("Chronic Conditions", chronicConditions,
                chronicConditionsList, "chronicConditions"),
            multiSelectOption(
                "Allergies", allergies, allergiesList, "allergies"),
            multiSelectOption("Triggers", triggers, triggersList, "triggers"),
            multiSelectOption("Dietary Preferences", dietaryPreferences,
                dietaryPreferencesList, "dietaryPreferences"),
            sectionTitle("Settings"),
            profileOption(icon: Icons.logout, title: "Log out", onTap: logout),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Future<String?> showEditDialog(
      BuildContext context, String title, String currentValue) async {
    TextEditingController controller =
        TextEditingController(text: currentValue);

    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $title"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter new $title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text("OK"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<List<String>?> showMultiSelectDialog(BuildContext context,
      String title, List<String> options, List<String> selectedValues) async {
    List<String> tempSelectedValues = List.from(selectedValues);

    return await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: MultiSelectDialogField(
            items: options.map((e) => MultiSelectItem<String>(e, e)).toList(),
            initialValue: selectedValues,
            onConfirm: (values) {
              tempSelectedValues = values.cast<String>();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, tempSelectedValues),
              child: Text("OK"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget profileOption(
      {required IconData icon,
      required String title,
      String? value,
      Function(String)? onEdit,
      VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: value != null
          ? Text(value, style: TextStyle(color: Colors.grey))
          : null,
      trailing: onEdit != null
          ? IconButton(
              icon: Icon(Icons.edit, size: 20, color: Colors.blueAccent),
              onPressed: () async {
                String? newValue =
                    await showEditDialog(context, title, value ?? "");
                if (newValue != null) onEdit(newValue);
              })
          : null,
      onTap: onTap,
    );
  }

  Widget multiSelectOption(String title, List<String> selectedValues,
      List<String> options, String field) {
    return ListTile(
      title: Text(title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: Text(selectedValues.join(", ") == ""
          ? "None selected"
          : selectedValues.join(", ")),
      trailing: Icon(Icons.arrow_drop_down),
      onTap: () async {
        List<String>? newValues = await showMultiSelectDialog(
            context, title, options, selectedValues);
        if (newValues != null) updateUserData(field, newValues);
      },
    );
  }
}
