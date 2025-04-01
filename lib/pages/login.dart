import 'dart:convert';
import 'package:bondify_chat/pages/register.dart';
import 'package:bondify_chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../conf.dart';
import '../services/user_provider.dart';
import 'chatlist.dart';

class LoginPage extends StatefulWidget {
  final bool isRedirected;

  LoginPage(this.isRedirected); // Constructor

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // if token exist ?
  ifTokenExist() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('user_token');
    if (token != null) {
      return true;
    }
  }

  final TextEditingController _usernameController = TextEditingController(text:'test');
  final TextEditingController _passwordController = TextEditingController(text: 'test');
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    print("widget.isRedirected"+widget.isRedirected.toString());
    if(widget.isRedirected){
      return;
    }

    // Buraya widget'ın başlangıç durumunu ayarlayabilirsiniz
    ifTokenExist().then((value) {
      if (value == true) {
        //new AuthService().tokenValidity().then((value) => null);
        new AuthService().tokenValidity().then((val)=>{
        if(val==true){
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatPage()),
        )
        }
        });
      }
    });
  }


  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', token);
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final response = await http.post(
      Uri.parse(Conf().url(UrlTypes.login)),
      body: json.encode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    ).catchError((onError) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Sunucu hatası. Lütfen tekrar deneyin.';
      });
      Fluttertoast.showToast(msg: "Sunucu hatası!", backgroundColor: Colors.red);
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Token'ı SharedPreferences'a kaydediyoruz
      await _saveToken(data['token']);
      // Token'ı UserProvider'a aktarıyoruz
      Provider.of<UserProvider>(context, listen: false).token = data['token'];
      Fluttertoast.showToast(msg: "Giriş başarılı!", backgroundColor: Colors.green);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatPage()));
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Giriş başarısız. Lütfen tekrar deneyin.';
      });
      Fluttertoast.showToast(
        msg: "Lütfen Giriş Yapınız",
        backgroundColor: Colors.red,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg2.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FontAwesomeIcons.comments, size: 80, color: Colors.brown),
                    SizedBox(height: 20),
                    Text(
                      "Bondify Chat",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.brown),
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person, color: Colors.lightGreen),
                        labelText: "Kullanıcı Adı",
                        filled: true,
                        fillColor: Colors.white12.withOpacity(0.8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Colors.lightGreen),
                        labelText: "Şifre",
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton.icon(
                      onPressed: _login,
                      icon: Icon(Icons.login),
                      label: Text("Giriş Yap"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                        textStyle: TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 15),
                    TextButton(
                      child: Text("Kayıt Ol", style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}