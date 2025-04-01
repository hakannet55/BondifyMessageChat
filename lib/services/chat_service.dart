import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../conf.dart';

class ChatService {

  // Fetch chat list from API with authentication
  Future<List> fetchChatList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse(new Conf().url(UrlTypes.messages)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      final messages = new Conf().parseJsonToList(response.body);
      return messages;
    } else {
      throw Exception('Failed to load chat list: ${response.body}');
    }
  }

  Future<bool> sendMessage(int userId,String text) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('user_token');

    if (token != null) {
      final response = await http.post(
        Uri.parse(new Conf().url(UrlTypes.sendmessages)+"/$userId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: json.encode({
          'userId': userId,
          'message':text,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to send message: ${response.body}');
      }
    }
    return false;
  }

  //fetchMessages
  Future<List<Map<String, dynamic>>> fetchMessages(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse(new Conf().url(UrlTypes.messages)+"/$userId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load chat list: ${response.body}');
    }
  }
  // fetchUsers
  Future fetchUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    print(token);
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.post(
      Uri.parse(new Conf().url(UrlTypes.users)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      final messages = new Conf().parseJsonToList(response.body);
      print(messages);
      return messages;
    } else {
      throw Exception('Failed to load chat list: ${response.body}');
    }
  }

}
