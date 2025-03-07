import 'package:flutter/material.dart';
import 'package:frontend/data/colors.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  int healthScore = 0;

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
1. Any *allergens* present and highlight them in red.
2. Any *ingredients that violate food preferences* and highlight them in red.
3. Any *ingredients that trigger dietary restrictions* and highlight them in red.
4. Calculate the *nutrition score* of the product.
5. Rate the *healthiness of the product* on a scale of 1 to 10.
6. Provide a *brief recommendation* on whether the user should consume this or avoid it.
7. Recommend any *alternative products* that are healthier.
Scanned Text: "${widget.scannedText}"

$userDetails

""";

    print("DEBUG: Sending prompt to API...");
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
        String rawText = responseData["candidates"]
                ?.first["content"]["parts"]
                ?.first["text"] ??
            "No response received";

        // Process text to replace <font color="red"> with Markdown
        String processedText = rawText.replaceAllMapped(
          RegExp(r'<font color="red">(.*?)<\/font>'),
          (match) => '**🔴 ${match.group(1)}**',
        );

        // Extract health score from the response (assuming it's provided in the response)
        int extractedHealthScore = _extractHealthScore(rawText);

        setState(() {
          isLoading = false;
          analysisResult = {"generated_text": processedText};
          healthScore = extractedHealthScore;
        });

        // Store the analysis result and alternatives in Firestore
        await _storeInFirestore(processedText);
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

  int _extractHealthScore(String text) {
    // Extract the health score from the text (assuming it's provided in the response)
    // This is a placeholder implementation and should be replaced with actual extraction logic
    final match = RegExp(r'healthiness of the product on a scale of 1 to 10: (\d+)')
        .firstMatch(text);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  Future<void> _storeInFirestore(String processedText) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Store the analysis result
      await FirebaseFirestore.instance.collection('scannedItems').add({
        'userId': user.uid,
        'scannedText': widget.scannedText,
        'imagePath': widget.imagePath,
        'analysisResult': processedText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Extract and store alternatives (assuming alternatives are provided in the response)
      final alternatives = _extractAlternatives(processedText);
      for (final alternative in alternatives) {
        await FirebaseFirestore.instance.collection('alternatives').add({
          'userId': user.uid,
          'originalProduct': widget.scannedText,
          'alternativeProduct': alternative,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      print("DEBUG: Stored in Firestore");
    }
  }

  List<String> _extractAlternatives(String text) {
    // Extract alternatives from the text (assuming they are provided in the response)
    // This is a placeholder implementation and should be replaced with actual extraction logic
    final alternatives = <String>[];
    final matches = RegExp(r'Recommend any alternative products that are healthier: (.*?)\n')
        .allMatches(text);
    for (final match in matches) {
      alternatives.add(match.group(1)!);
    }
    return alternatives;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Food Analysis Results"),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Scanned Image:",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor),
                    ),
                    SizedBox(height: 10),
                    Image.file(File(widget.imagePath), height: 300),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(
                          'assets/red.png',
                          height: 50,
                          color: healthScore <= 3 ? Colors.red : Colors.grey,
                        ),
                        Image.asset(
                          'assets/yellow.png',
                          height: 50,
                          color: healthScore > 3 && healthScore <= 7
                              ? Colors.yellow
                              : Colors.grey,
                        ),
                        Image.asset(
                          'assets/green.png',
                          height: 50,
                          color: healthScore > 7 ? Colors.green : Colors.grey,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    analysisResult != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (analysisResult!["generated_text"] != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Nutritionist's Analysis:",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor),
                                    ),
                                    SizedBox(height: 10),
                                    MarkdownBody(
                                      data: analysisResult!["generated_text"],
                                      styleSheet: MarkdownStyleSheet(
                                        strong: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red),
                                        h1: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                        h2: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                        p: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87),
                                      ),
                                    ),
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _storeInFirestore(analysisResult!["generated_text"]);
                          print("DEBUG: Store in Store button clicked.");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                        ),
                        child: Text("Store in Store"),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}