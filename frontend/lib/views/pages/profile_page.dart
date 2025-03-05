import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool aiRecommendations = true; // Toggle state for AI Recommendations

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
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
                    backgroundImage: AssetImage(
                        'assets/profile.jpg'), // Replace with NetworkImage() if fetching online
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
                    'Akshay Rajput',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '@rajputakshay8940',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Sections
            sectionTitle("Food & Health"),
            profileOption(Icons.restaurant, "Daily Intake", context),
            profileOption(Icons.fastfood, "Dietary Preferences", context),
            profileOption(Icons.warning_amber_rounded, "Allergens", context),

            sectionTitle("Food Management"),
            profileOption(Icons.store, "My Store", context),
            profileOption(Icons.date_range, "Expiry Tracking", context),

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
            profileOption(Icons.logout, "Log out", context),
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

  Widget profileOption(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.arrow_forward_ios, size: 18),
      onTap: () {
        // Navigate to respective pages
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
