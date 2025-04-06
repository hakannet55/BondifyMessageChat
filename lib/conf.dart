import 'dart:convert';

enum UrlTypes { login, register, messages,users,tokenValidity,sendmessages }
class Conf{
  bool isDebug = true;
  static String baseUrl = "https://node-js-backend-chat-api.vercel.app/";
  static String local = 'http://localhost:3000/';
  //function url +base + url
  String url(UrlTypes url){
    return (isDebug ? local:baseUrl)+url.name;
  }

  // utils.dart
  List<dynamic> parseJsonToList(String responseBody) {
    final jsonData = json.decode(responseBody);
    if (jsonData is List<dynamic>) {
      final array= jsonData as List<dynamic>;
      for (var i = 0; i < array.length; i++) {
        final item = array[i];
        if (item is Map<String, dynamic>) {
          array[i] = item;
        }
      }
      return array;
    } else {
      throw Exception('Invalid JSON response');
    }
  }
}

