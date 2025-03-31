import 'dart:convert';
import 'package:chat_application/pages/register.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../conf.dart';
import '../main.dart';
import '../services/user_provider.dart';
import 'chatlist.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false; // Yükleniyor göstergesi için

  // Token'ı SharedPreferences'a kaydedelim
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', token);
  }

  // Giriş fonksiyonu
  Future<void> _login() async {
    setState(() {
      _isLoading = true;  // Yükleniyor durumunu başlat
      _errorMessage = '';  // Hata mesajını sıfırlayalım
    });

    final response = await http.post(
      Uri.parse(new Conf().url(UrlTypes.login)),
      body: json.encode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Token'ı SharedPreferences'a kaydediyoruz
      await _saveToken(data['token']);

      // Provider üzerinden token'ı ayarlıyoruz
      Provider.of<UserProvider>(context, listen: false).token = data['token'];

      // Başarılı giriş sonrası chat sayfasına yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatPage()),
      );
    } else {
      setState(() {
        _isLoading = false;  // Yükleniyor durumunu bitir
        _errorMessage = 'Giriş başarısız. Lütfen tekrar deneyin.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Giriş Yap')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Kullanıcı Adı'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Şifre'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()  // Yükleniyor göstergesi
                : ElevatedButton(
              onPressed: _login,
              child: Text('Giriş Yap'),
            ),
            SizedBox(height: 10),
            Text(_errorMessage, style: TextStyle(color: Colors.red)),
            TextButton(
              child: Text('Kayıt Ol'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
