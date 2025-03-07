import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalysisPage extends StatefulWidget {
  final String scannedText;
  final String imagePath;

  AnalysisPage({required this.scannedText, required this.imagePath});

  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  Map<String, dynamic>? analysisResult;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    sendToGemini();
  }

  Future<void> sendToGemini() async {
    print("DEBUG: Loading API Key...");
    final String? apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      print("ERROR: API Key not found.");
      setState(() {
        isLoading = false;
        analysisResult = {"error": "API key not found"};
      });
      return;
    }
    print("DEBUG: API Key loaded successfully.");

    const String apiUrl =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "parts": [
            {"text": widget.scannedText}
          ]
        }
      ]
    };

    print("DEBUG: Sending request to Gemini API...");
    print("DEBUG: Request Body: ${jsonEncode(requestBody)}");

    try {
      final response = await http.post(
        Uri.parse("$apiUrl?key=$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("DEBUG: Response Status Code: ${response.statusCode}");
      print("DEBUG: Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic>? candidates = responseData["candidates"];

        if (candidates != null && candidates.isNotEmpty) {
          final generatedText = candidates[0]["content"]["parts"][0]["text"];
          print("DEBUG: Successfully received analysis from Gemini.");

          setState(() {
            analysisResult = {"generated_text": generatedText};
            isLoading = false;
            print("DEBUG: Updated analysisResult: $analysisResult");
          });
        } else {
          print("ERROR: No valid response from Gemini.");
          setState(() {
            analysisResult = {"error": "No valid response from Gemini"};
            isLoading = false;
          });
        }
      } else {
        print("ERROR: Failed to fetch analysis. HTTP ${response.statusCode}");
        setState(() {
          analysisResult = {
            "error": "Failed to fetch analysis (HTTP ${response.statusCode})"
          };
          isLoading = false;
        });
      }
    } catch (e) {
      print("EXCEPTION: $e");
      setState(() {
        analysisResult = {"error": "Exception: $e"};
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Analysis Results")),
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
                    Text(
                      widget.scannedText,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text("Scanned Image:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Image.file(File(widget.imagePath), height: 300),
                    SizedBox(height: 20),

                    /// Display Gemini Analysis Results
                    analysisResult != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (analysisResult!["generated_text"] != null)
                                Text(
                                  "Generated Analysis:",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              SizedBox(height: 10),
                              if (analysisResult!["generated_text"] != null)
                                Text(
                                  analysisResult!["generated_text"],
                                  style: TextStyle(fontSize: 16),
                                ),
                            ],
                          )
                        : Text("No analysis available.",
                            style: TextStyle(fontSize: 16, color: Colors.red)),

                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Handle storing the result
                        print("DEBUG: Store in Store button clicked.");
                      },
                      child: Text("Store in Store"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
