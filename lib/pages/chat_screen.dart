import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final int userId;
  final String targetUserName;
  const ChatScreen({Key? key, required this.userId,required this.targetUserName}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState(userId,targetUserName);
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> _messages = [];
  bool loader = true;
  final ScrollController _scrollController = ScrollController(); // Scroll controller tanımla

  final int userId;
  final String targetUserName;
  final _chatService = ChatService();
  _ChatScreenState(this.userId,this.targetUserName);

  @override
  void dispose() {
    _scrollController.dispose(); // Bellek sızıntısını önlemek için dispose et
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadMessages();
    // control new messages interval time
    Timer.periodic(Duration(seconds: 15), (timer) {
      _loadMessages();
    });
  }

  Future<void> _loadMessages() async {
    final messages = await _chatService.fetchMessages(userId);
    setState(() {
      loader = false;
      _messages = messages;
      toBottom();
    });
  }

  Future<void> _sendMessage() async {
  final res = await _chatService.sendMessage(userId,_messageController.text);
      if(res == true){
       setState(() {
         _messages.add({
           "id": userId,
           "message": _messageController.text
         });
       });
       _messageController.clear();
        toBottom();
     }else{
       //Fluttertoast err
       Fluttertoast.showToast(msg: "Sunucu hatası!", backgroundColor: Colors.red);
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Row(children: [CircleAvatar(
        backgroundColor:
        Colors.deepPurpleAccent, // Avatar rengi
        child: Text(
          targetUserName[0].toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),Text(targetUserName,style: TextStyle(fontWeight: FontWeight.bold)),Text("  -  "),Text("Sohbet")])),
      body: Column(
        children: [
          loader ?
          Center(child: CircularProgressIndicator()) :
          _messages ==null || _messages.isEmpty || _messages.length == 0 ?
          Text("Henüz hicbir mesajınız yok") :
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // ScrollController'ı buraya bağla
              itemCount: _messages.length,
              //align rigth
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(8.0),
                  alignment: isSame(index) ? Alignment.centerRight : Alignment.centerLeft,
                    color: isSame(index) ? Color.fromRGBO(200, 200, 250, 50) : Colors.grey[300],
                    child: ListTile( title: Text(getTextMessage(index))));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(labelText: 'Mesajınızı yazın'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isSame(int index) {
    final message = _messages[index];
    if (message['id'] == userId) {
      return true;
    } else {
      return false;
    }
  }

  String getTextMessage(int index) {
    if(_messages.length == 0){
      return "-";
    }
    final message = _messages[index];
    if (!isSame(index)) {
      return 'Ben: ${message['message']}';
    } else {
      return 'Birisi: ${message['message']}';
    }
  }

  void toBottom() {
    // autoscroll to bottom
    Future.delayed(Duration(milliseconds: 100), () {
      if(_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
      // _scrollController.animateTo(
      //     _scrollController.position.maxScrollExtent,
      //     duration: Duration(milliseconds: 300),
      //     curve: Curves.easeOut
      // );
    });
  }
}
