import 'dart:convert';

import 'package:bondify_chat/pages/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/user_provider.dart';
import 'chat_screen.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<dynamic> _userList = [];
  bool isEmpty=false;
  final _chatService =
      ChatService(); // ChatService sınıfının bir örneği oluşturun
  //final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserList();
  }

  Future<void> _loadUserList() async {
    //final token = Provider.of<UserProvider>(context, listen: false).token;
    //final userId =_authService.getTokenUserId();
    final userList = await _chatService.fetchUsers();
    print(userList);
    setState(() {
      if(userList.isEmpty) isEmpty=true;
      _userList = userList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Row(children: [Text('Kullanıcılar'),
      // quoit button
      Spacer(),
        Row(children: [IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            // navigate login
            Fluttertoast.showToast(msg: "Test");
          },
        ),
          Text("Ara")],),
        Spacer(),
      Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                // navigate login
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage(true)),
                );
              },
            ),  Text("Çıkış")
          ],
        ),
      )],)),
      body:
      isEmpty? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Kullanıcı bulunamadı",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // navigate login
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage(true)),
                );

                },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("Ana Sayfa", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ) : _userList.isEmpty
              ? Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
              : ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: _userList.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5, // Hafif gölgelendirme
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      leading: CircleAvatar(
                        backgroundColor:
                            Colors.deepPurpleAccent, // Avatar rengi
                        child: Text(
                          _userList[index]['username'][0].toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        _userList[index]['username'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Son konuşmalar...",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      trailing: Icon(
                        Icons.chat_bubble,
                        color: Colors.deepPurpleAccent,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ChatScreen(userId: _userList[index]['id']
                                        ,targetUserName: _userList[index]['username']),
                          ),
                        );
                      },
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
