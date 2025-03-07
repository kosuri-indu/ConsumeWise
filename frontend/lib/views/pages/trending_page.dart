import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class TrendingPage extends StatefulWidget {
  @override
  _TrendingPageState createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
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
      "**Food Recommendations**: Suggest foods for **$chronicIllness** while avoiding **$allergies** and **$foodTriggers** within a **$dietaryPreferences** diet.\n\nUse bullet points, bold headers, and markdown formatting.",
      "**Trending Indian Recipes**: Recommend trending **homemade Indian recipes** suitable for a **$dietaryPreferences** diet. Use markdown with numbered steps.",
      "**Exercise & Lifestyle Tips**: Provide effective **at-home exercises** and **lifestyle tips** for managing **$chronicIllness**. Highlight key exercises using **bold text** and bullet points."
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
      appBar: AppBar(title: Text("Trending Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userInfo == null || geminiResponses.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  _buildUserInfo(),
                  _buildSection("Recommended Foods",
                      geminiResponses.values.elementAtOrNull(0)),
                  _buildSection("Trending Homemade Indian Recipes",
                      geminiResponses.values.elementAtOrNull(1)),
                  _buildSection("Exercise & Chronic Cure Techniques",
                      geminiResponses.values.elementAtOrNull(2)),
                ],
              ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow("Name", userInfo?['name']),
        _buildInfoRow("Weight", userInfo?['weight']),
        _buildInfoRow("Gender", userInfo?['gender']),
        _buildInfoRow("Chronic Illness", chronicIllness),
        _buildInfoRow("Allergies", allergies),
        _buildInfoRow("Food Sensitivities", foodTriggers),
        _buildInfoRow("Dietary Preferences", dietaryPreferences),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value?.toString() ?? "N/A"),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String? content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(thickness: 2, color: Colors.blueAccent),
        SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            decorationColor: Colors.blue,
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
                      color: Colors.blue),
                  h2: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                  p: TextStyle(fontSize: 16, color: Colors.black87),
                  strong:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  em: TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.purple),
                  blockquote: TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              )
            : Text("No data available"),
        SizedBox(height: 20),
      ],
    );
  }
}
