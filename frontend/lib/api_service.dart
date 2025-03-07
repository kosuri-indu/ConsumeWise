import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String message = "Fetching data...";
  List<int> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.46.61:5000/api/data'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          message = jsonResponse['message'];
          data = List<int>.from(jsonResponse['data']);
        });
      } else {
        setState(() {
          message = "Failed to fetch data: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        message = "Error fetching data: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Python Integration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(message),
              const SizedBox(height: 20),
              data.isNotEmpty
                  ? Column(
                      children:
                          data.map((item) => Text(item.toString())).toList(),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => fetchData(),
        tooltip: 'Send Message',
        child: const Icon(Icons.send),
      ),
    );
  }
}
