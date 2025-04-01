import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../conf.dart';

class AuthService {
  Future<bool> tokenValidity() async {
    final token = await getToken();
    if (token == null) {
      return false;
    }
    final response = await http.post(
      Uri.parse(new Conf().url(UrlTypes.tokenValidity)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );
    return response.body == "1";
  }
  // API'den gelen yanıt ile token'ı almak ve saklamak
  Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(new Conf().url(UrlTypes.login)),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Token'ı SharedPreferences'a kaydediyoruz
      _saveToken(data['token']);

      return data['token'];
    } else {
      throw Exception('Giriş başarısız');
    }
  }

  // Token'ı SharedPreferences'a kaydetmek
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', token);
  }

  // Token'ı SharedPreferences'dan almak
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token');
  }

  // Token'ı temizlemek (çıkış yapma)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
  }

  int getTokenUserId() {
    // example tokens="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJrZXkiOiJ2YWx1ZSIsImtleTIiOiJ2YWx1ZTIiLCJpYXQiOjE2MzQxNzgxMTB9.vnXM0oxw05QH1Vs6RsvYp6LaEqFFqZ-NExQMXBgP7Mk";
    // jwt token datasını almak
    final token = getToken();
    final tokenParts = token?.toString().split('.');
    if(tokenParts==null || tokenParts!.length < 2) return 0;

    final payload = tokenParts?[1];
    final payloadJson = json.decode(utf8.decode(base64.decode(payload!)));
    return int.parse(payloadJson['id']);
  }
}
