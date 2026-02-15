import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.6:8000";

  static Future<Map<String, dynamic>> predict(
      String imagePath, String userEmail) async {

    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/predict?user=$userEmail"),
    );

    request.files.add(
      await http.MultipartFile.fromPath("file", imagePath),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    return jsonDecode(responseBody);
  }

  static Future<List<dynamic>> getHistory(String userEmail) async {
  final response = await http.get(
    Uri.parse("$baseUrl/history?user=$userEmail"),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to load history");
  }
}

static Future<String> chatWithContext(
  String user,
  String question,
  String prediction,
) async {
  final response = await http.post(
    Uri.parse("$baseUrl/chat"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "user": user,
      "question": question,
      "prediction": prediction,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)["answer"];
  } else {
    return "AI assistant unavailable.";
  }
}

}
