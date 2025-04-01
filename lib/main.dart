import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/login.dart'; // Veya ilgili sayfa
import 'services/user_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        title: 'Chat Application',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LoginPage(false), // Ana giriş sayfası
      ),
    );
  }
}
