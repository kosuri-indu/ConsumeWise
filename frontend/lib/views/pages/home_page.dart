import 'package:flutter/material.dart';
import 'package:frontend/views/pages/trending_page.dart';
import 'profile_page.dart';
import 'scanning_page.dart';
import 'package:frontend/data/colors.dart'; // Import your colors file

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🏆 Title & Subtitle
              Text(
                "Conquer Chronicles with Care",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Make informed choices by scanning labels and tracking ingredients effortlessly!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              // 🖼️ Centered Image
              Image.asset('assets/home.png',
                  height: 250, width: 250, fit: BoxFit.contain),
              SizedBox(height: 20),

              // 🌟 Features Section
              Column(
                children: [
                  _buildFeatureCard(
                    icon: Icons.search,
                    title: "Scan Labels",
                    description:
                        "Quickly scan food labels to get detailed information about ingredients and nutritional values.",
                  ),
                  _buildFeatureCard(
                    icon: Icons.trending_up,
                    title: "Trending Foods",
                    description:
                        "Stay updated with the latest trending foods and recipes tailored to your preferences.",
                  ),
                  _buildFeatureCard(
                    icon: Icons.person,
                    title: "Personalized Profile",
                    description:
                        "Manage your dietary preferences and health information in your personalized profile.",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ScanningPage(
                        userProfile: {},
                      )));
        },
        backgroundColor: primaryColor,
        shape: CircleBorder(),
        child: Icon(Icons.camera_alt, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: Icon(Icons.home), onPressed: () {}),
            IconButton(icon: Icon(Icons.store), onPressed: () {}),
            SizedBox(width: 40), // Space for Floating Button
            IconButton(
              icon: Icon(Icons.trending_up),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TrendingPage()));
              },
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      {required IconData icon,
      required String title,
      required String description}) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: primaryColor),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor),
                  ),
                  SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
