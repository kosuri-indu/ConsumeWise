import 'package:flutter/material.dart';
import 'package:frontend/views/pages/signin_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Center everything
            children: [
              // Logo (Heart-shaped image)
              Image.asset('assets/logo.png', height: 320),

              const SizedBox(height: 50),

              // Text Section
              Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                            text: "Scan ",
                            style: TextStyle(color: Colors.orange)),
                        TextSpan(
                            text: "Smarter\n",
                            style: TextStyle(color: Colors.black)),
                        TextSpan(
                            text: "Eat ",
                            style: TextStyle(color: Colors.black)),
                        TextSpan(
                            text: "Healthier",
                            style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Stay healthy by tracking every meal.",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const SizedBox(height: 50),

              // // Button Section
              // Column(
              //   children: [
              //     GestureDetector(
              //       onTap: () {
              //         Navigator.pushReplacement(
              //           context,
              //           MaterialPageRoute(
              //               builder: (context) => const SignInPage()),
              //         );
              //       },
              //       child: Container(
              //         width: 250,
              //         padding: const EdgeInsets.symmetric(vertical: 14),
              //         decoration: BoxDecoration(
              //           color: Color(0xFFCDE26E), // Light green color
              //           borderRadius: BorderRadius.circular(30),
              //         ),
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: const [
              //             Text(
              //               "Get Started",
              //               style: TextStyle(
              //                   color: Colors.white,
              //                   fontSize: 20,
              //                   fontWeight: FontWeight.bold),
              //             ),
              //             SizedBox(width: 10),
              //             Icon(Icons.brightness_2,
              //                 color: Colors.white, size: 20),
              //           ],
              //         ),
              //       ),
              //     ),
              //     // const SizedBox(height: 10),
              //     // TextButton(
              //     //   onPressed: () {
              //     //     Navigator.pushReplacement(
              //     //       context,
              //     //       MaterialPageRoute(
              //     //           builder: (context) => const SignInPage()),
              //     //     );
              //     //   },
              //     //   child: const Text(
              //     //     "Skip",
              //     //     style: TextStyle(color: Colors.grey, fontSize: 16),
              //     //   ),
              //     // ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
