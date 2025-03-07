import 'package:flutter/material.dart';
import 'dart:async';
import 'package:frontend/views/pages/trending_page.dart';
import 'profile_page.dart';
import 'scanning_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..repeat(reverse: true); // Continuous up-down animation

    _arrowAnimation = Tween<double>(begin: 0, end: 10).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🏆 Title & Subtitle
            Text(
              "Conquer Chronicles with Care",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "Make informed choices by scanning labels and tracking ingredients effortlessly!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // 🖼️ Centered Image
            Image.asset('assets/home.png',
                height: 200, width: 200, fit: BoxFit.contain),
            SizedBox(height: 20),

            // 🏆 Animated Arrow above the FAB
            AnimatedBuilder(
              animation: _arrowAnimation,
              builder: (context, child) {
                return Padding(
                  padding: EdgeInsets.only(bottom: _arrowAnimation.value),
                  child: Icon(Icons.keyboard_arrow_down,
                      size: 40, color: Colors.blue),
                );
              },
            ),
          ],
        ),
      ),

      // 🎯 Floating Action Button (FAB) for Scanning
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ScanningPage()));
        },
        backgroundColor: Theme.of(context).primaryColor,
        shape: CircleBorder(),
        child: Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 🔽 Bottom Navigation Bar
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
}
