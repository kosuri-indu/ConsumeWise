import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AnalysisPage extends StatefulWidget {
  final String scannedText;
  final String imagePath;
  final Map<String, dynamic> userProfile;

  AnalysisPage({
    required this.scannedText,
    required this.imagePath,
    required this.userProfile,
  });

  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  Map<String, dynamic>? analysisResult;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => sendToGemini());
  }

  Future<void> sendToGemini() async {
    print("DEBUG: Fetching API Key...");
    await dotenv.load(fileName: "assets/.env");
    final String? apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      print("ERROR: API Key not found.");
      setState(() {
        isLoading = false;
        analysisResult = {"error": "API key not found"};
      });
      return;
    }
    print("DEBUG: API Key Loaded.");

    const String apiUrl =
        "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent";

    List<String> allergies =
        List<String>.from(widget.userProfile["allergies"] ?? []);
    String formattedAllergies =
        allergies.isNotEmpty ? allergies.join(", ") : "None";

    List<String> triggers =
        List<String>.from(widget.userProfile["triggers"] ?? []);
    String formattedTriggers =
        triggers.isNotEmpty ? triggers.join(", ") : "None";

    List<String> dietaryPreferences =
        List<String>.from(widget.userProfile["dietary_preferences"] ?? []);
    String formattedDietaryPreferences =
        dietaryPreferences.isNotEmpty ? dietaryPreferences.join(", ") : "None";

    final String userDetails = """
User Profile:
- Age: ${widget.userProfile["age"] ?? "Unknown"}
- Weight: ${widget.userProfile["weight"] ?? "Unknown"}
- Gender: ${widget.userProfile["gender"] ?? "Unknown"}
- Chronic Illness: ${widget.userProfile["chronic_conditions"] ?? "None"}
- Allergies: $formattedAllergies
- Food Triggers: $formattedTriggers
- Dietary Preferences: $formattedDietaryPreferences
""";

    final String prompt = """
Analyze the following food label for a user with the given profile. Identify:
1. Any *allergens* present.
2. Any *ingredients that violate food preferences*.
3. Any *ingredients that trigger dietary restrictions*.
4. Rate the *healthiness of the product* on a scale of 1 to 10.
5. Provide a *brief recommendation* on whether the user should consume this or avoid it.

Scanned Text: "${widget.scannedText}"

$userDetails

Provide dietary recommendations and insights based on the user's conditions.
""";

    print("DEBUG: Sending prompt to API...");
    print("DEBUG: Prompt: $prompt");
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
        setState(() {
          isLoading = false;
          analysisResult = {
            "generated_text": responseData["candidates"]
                    ?.first["content"]["parts"]
                    ?.first["text"] ??
                "No response received"
          };
        });
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        setState(() {
          isLoading = false;
          analysisResult = {
            "error": "API response error: ${response.statusCode}"
          };
        });
      }
    } catch (e) {
      print("Error fetching response: $e");
      setState(() {
        isLoading = false;
        analysisResult = {"error": "Error fetching response"};
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Food Analysis Results")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Extracted Text:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(widget.scannedText, style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                    Text("Scanned Image:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Image.file(File(widget.imagePath), height: 300),
                    SizedBox(height: 20),
                    analysisResult != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (analysisResult!["generated_text"] != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Nutritionist's Analysis:",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 10),
                                    Text(analysisResult!["generated_text"],
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                )
                              else if (analysisResult!["error"] != null)
                                Text("Error: ${analysisResult!["error"]}",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.red)),
                            ],
                          )
                        : Text("No analysis available.",
                            style: TextStyle(fontSize: 16, color: Colors.red)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () =>
                          print("DEBUG: Store in Store button clicked."),
                      child: Text("Store in Store"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
