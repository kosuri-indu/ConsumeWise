import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://192.168.1.4:5000'; // Adjust the URL as needed

  static Future<Map<String, dynamic>> processImage(File imageFile) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/process_image'));
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      return json.decode(responseData);
    } else {
      throw Exception('Failed to process image');
    }
  }
}
