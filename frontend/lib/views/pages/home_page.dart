import 'package:flutter/material.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage()), // Navigate to Profile Page
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            greetingSection(),
            SizedBox(height: 20),
            homeCard(Icons.restaurant, "Daily Intake", "1200 / 2000 kcal"),
            homeCard(Icons.store, "My Store", "Check your items"),
            homeCard(Icons.warning_amber, "Expiring Soon",
                "Track items nearing expiry"),
            homeCard(Icons.auto_awesome, "AI Suggestions",
                "Get personalized recommendations"),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage()), // Navigate to Scanning Page
          );
        },
        child: Icon(Icons.camera_alt),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.store),
              onPressed: () {}, // Future Store Page
            ),
            SizedBox(width: 40), // Space for Floating Button
            IconButton(
              icon: Icon(Icons.bar_chart),
              onPressed: () {}, // Future Insights Page
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage()), // Navigate to Profile Page
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget greetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("👋 Good Morning!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text("📅 Today: Mar 5 | 🌤  27°C",
            style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget homeCard(IconData icon, String title, String subtitle) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey)),
        trailing: Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          // Placeholder for future navigation
        },
      ),
    );
  }
}
