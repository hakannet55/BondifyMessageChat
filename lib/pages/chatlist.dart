import 'dart:async';
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
  String _loginUserName="";
  AuthService _authService = AuthService();
  final _chatService =
      ChatService(); // ChatService sınıfının bir örneği oluşturun

  @override
  void initState() {
    super.initState();
    _loadUserList();
    _authService.getTokenUserName().then((value) {
      print("value");
      print(value);
      _loginUserName=value;
    });
    // interval 5 second refresh, infinity
    Timer.periodic(Duration(seconds: 15), (timer) {
      _loadUserList();
    });
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
        //button refles
      ListView(
            children: [
      Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Text(
        'Login:'+ _loginUserName,
        style: TextStyle(fontSize: 18),
      ),
      ElevatedButton(
        onPressed: () {
          // Yenileme işlemi burada yapılır
          print('Yenileme düğmesine tıklandı!');
        },
        child: Text('Yenile'),
      ),
        ],
      ),
      ),

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
        ) : Column( children:renderListTileItems(_userList,context)
      ),
      ])
    );
  }

  List<Widget> renderListTileItems(List userList,BuildContext context) {
  final List<Widget> ary=[];
  for (int i = 0; i < userList.length; i++) {
    final item=userList[i];
    ary.add(ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      leading: CircleAvatar(
        backgroundColor:
        Colors.deepPurpleAccent, // Avatar rengi
        child: Text(
          item['username'][0].toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(item['username'],
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
                ChatScreen(userId: 123,targetUserName:item['username']),
          ),
        );
      },
    ));
  }
  return ary;
  }

}

