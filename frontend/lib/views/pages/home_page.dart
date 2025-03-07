import 'package:flutter/material.dart';
import 'package:frontend/views/pages/trending_page.dart';
import 'profile_page.dart';
import 'scanning_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "Welcome to Your Dashboard",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScanningPage()),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        shape: CircleBorder(),
        child: Icon(Icons.add, size: 32, color: Colors.white),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {}, // Home Page (Already on it)
            ),
            IconButton(
              icon: Icon(Icons.store),
              onPressed: () {}, // Store Page
            ),
            SizedBox(width: 40), // Space for Floating Button
            IconButton(
              icon: Icon(Icons.trending_up),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrendingPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person),
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
