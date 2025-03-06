import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/views/pages/signin_page.dart';
import 'package:frontend/views/pages/about_me_page.dart';

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

          // Fetch weight and unit separately and combine them
          String weightValue = userDoc['weight']?.toString() ?? "N/A";
          String unit = userDoc['unit'] ?? "";
          userWeight = unit.isNotEmpty ? "$weightValue $unit" : weightValue;
        });
      }
    }
  }

  void updateUserData(String field, String newValue) async {
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
      });
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
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
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings page
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            // Profile Image & Name
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
                  Text(
                    userName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            sectionTitle("Personal Information"),

            profileOption(
              icon: Icons.person,
              title: "Name",
              value: userName,
              onEdit: (newValue) {
                updateUserData("name", newValue);
              },
            ),

            profileOption(
              icon: Icons.cake,
              title: "Age",
              value: userAge,
              onEdit: (newValue) {
                updateUserData("age", newValue);
              },
            ),

            profileOption(
              icon: Icons.male,
              title: "Gender",
              value: userGender,
              onEdit: (newValue) {
                updateUserData("gender", newValue);
              },
            ),

            profileOption(
              icon: Icons.monitor_weight,
              title: "Weight",
              value: userWeight,
              onEdit: (newValue) {
                updateUserData("weight", newValue);
              },
            ),

            sectionTitle("Food & Health"),

            profileOption(icon: Icons.restaurant, title: "Daily Intake"),
            profileOption(icon: Icons.fastfood, title: "Dietary Preferences"),
            profileOption(
                icon: Icons.warning_amber_rounded, title: "Allergens"),

            sectionTitle("Food Management"),

            profileOption(icon: Icons.store, title: "My Store"),
            profileOption(icon: Icons.date_range, title: "Expiry Tracking"),

            sectionTitle("Settings"),
            ListTile(
              leading: Icon(Icons.auto_awesome, color: Colors.blueAccent),
              title: Text("AI Recommendations",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              trailing: Switch(
                value: aiRecommendations,
                onChanged: (bool value) {
                  setState(() {
                    aiRecommendations = value;
                  });
                },
              ),
            ),

            profileOption(
              icon: Icons.person,
              title: "About Me",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutMePage(
                      name: userName,
                      age: userAge,
                      gender: userGender,
                      weight: userWeight,
                    ),
                  ),
                );
              },
            ),

            profileOption(
              icon: Icons.logout,
              title: "Log out",
              onTap: logout,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: Icon(Icons.home), onPressed: () {}),
            IconButton(icon: Icon(Icons.bar_chart), onPressed: () {}),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add action
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget profileOption({
    required IconData icon,
    required String title,
    String? value,
    Function(String)? onEdit,
    VoidCallback? onTap,
  }) {
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
                if (newValue != null) {
                  onEdit(newValue);
                }
              },
            )
          : null,
      onTap: onTap, // This will trigger navigation
    );
  }

  Future<String?> showEditDialog(
      BuildContext context, String field, String currentValue) async {
    TextEditingController controller =
        TextEditingController(text: currentValue);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $field"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter new $field"),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: Text("Save")),
          ],
        );
      },
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ),
    );
  }
}
