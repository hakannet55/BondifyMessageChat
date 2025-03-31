import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sohbetler')),
      body: ListView.builder(
        itemCount: 10, // Burada sabit sayıda chat gösteriyoruz
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Kullanıcı #$index'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              );
            },
          );
        },
      ),
    );
  }
}
