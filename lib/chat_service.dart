import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatService {
  // Method to send message to the server and receive the response
  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData["response"];
      } else {
        return "Sorry, something went wrong.";
      }
    } catch (e) {
      return "Unable to connect to the server.";
    }
  }
}
