import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:frontend/data/colors.dart';

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  Map<String, dynamic>? userInfo;
  Map<String, String> geminiResponses = {};

  String chronicIllness = 'General';
  String dietaryPreferences = 'General';
  String allergies = 'None';
  String foodTriggers = 'None';

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userInfo = userDoc.data() as Map<String, dynamic>?;
            _extractUserPreferences();
          });
          _generateAndSendPrompts();
        }
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  void _extractUserPreferences() {
    setState(() {
      chronicIllness = _parseListField(userInfo?['chronic_conditions']);
      dietaryPreferences = _parseListField(userInfo?['dietary_preferences']);
      allergies = _parseListField(userInfo?['allergies'], defaultValue: 'None');
      foodTriggers =
          _parseListField(userInfo?['triggers'], defaultValue: 'None');
    });
  }

  String _parseListField(dynamic field, {String defaultValue = 'General'}) {
    if (field is List) {
      return field.join(', ');
    } else if (field is String) {
      return field;
    } else {
      return defaultValue;
    }
  }

  Future<void> _generateAndSendPrompts() async {
    List<String> prompts = [
      "You are a chronic illness doctor who is sweet and motivating. Your tone is kind yet professional, offering clear, supportive, and uplifting guidance to patients managing chronic conditions. Suggest alternative food products for someone with **$chronicIllness**, considering their **$allergies**, **$foodTriggers**, and **$dietaryPreferences** diet. Use bullet points, bold headers, markdown formatting, and only 200 words."
    ];

    Map<String, String> responses = await _sendPromptsToGemini(prompts);
    setState(() {
      geminiResponses = responses;
    });
  }

  Future<Map<String, String>> _sendPromptsToGemini(List<String> prompts) async {
    final String? apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      print("ERROR: API Key not found.");
      return {for (var prompt in prompts) prompt: "API key missing"};
    }

    const String apiUrl =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";
    Map<String, String> responses = {};

    for (String prompt in prompts) {
      try {
        final response = await http.post(
          Uri.parse("$apiUrl?key=$apiKey"),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "contents": [
              {
                "parts": [
                  {"text": prompt}
                ]
              }
            ]
          }),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          responses[prompt] = responseData["candidates"]
                  ?.first["content"]["parts"]
                  ?.first["text"] ??
              "No response received";
        } else {
          responses[prompt] = "Error: ${response.statusCode}";
        }
      } catch (e) {
        responses[prompt] = "Error fetching response";
      }
    }
    return responses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alternative Food Suggestions"),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userInfo == null || geminiResponses.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  _buildSection("Alternative Food Products",
                      geminiResponses.values.first),
                ],
              ),
      ),
    );
  }

  Widget _buildSection(String title, String? content) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 5),
            content != null
                ? MarkdownBody(
                    data: content,
                    styleSheet: MarkdownStyleSheet(
                      h1: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor),
                      p: TextStyle(fontSize: 16, color: Colors.black87),
                      strong: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  )
                : Text("No data available"),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
