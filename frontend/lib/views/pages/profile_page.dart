import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/views/pages/signin_page.dart';
import 'package:frontend/views/pages/home_page.dart';
import 'package:frontend/views/pages/trending_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
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
            // Fixed Logout Button
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Log out", style: TextStyle(color: Colors.red)),
              onTap: logout,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.green[700],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.store, color: Colors.white),
              onPressed: () {},
            ),
            SizedBox(width: 40),
            IconButton(
              icon: Icon(Icons.trending_up, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrendingPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Section Title Widget
Widget sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

// Profile Option Widget
Widget profileOption({
  required IconData icon,
  required String title,
  required String value,
  required Function(String) onEdit,
}) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(value),
    trailing: IconButton(
      icon: Icon(Icons.edit),
      onPressed: () async {
        String? newValue = await showEditDialog(title, value);
        if (newValue != null && newValue.isNotEmpty) {
          onEdit(newValue);
        }
      },
    ),
  );
}

// Show Edit Dialog Function
Future<String?> showEditDialog(String field, String initialValue) async {
  TextEditingController controller = TextEditingController(text: initialValue);
  return await showDialog<String>(
    context: navigatorKey.currentContext!,
    builder: (context) {
      return AlertDialog(
        title: Text("Edit $field"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Save"),
            onPressed: () => Navigator.pop(context, controller.text),
          ),
        ],
      );
    },
  );
}

// Global Navigator Key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
