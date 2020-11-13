import 'package:agora_voice/voice_call.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(VoiceCall());
}

class VoiceCall extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VoiceCallStateful(),
    );
  }
}

class VoiceCallStateful extends StatefulWidget {
  _VoiceCallState createState() => _VoiceCallState();
}

class _VoiceCallState extends State<VoiceCallStateful> {
  TextEditingController _channel, _username;

  void initState() {
    super.initState();
    _channel = TextEditingController();
    _username = TextEditingController();
  }

  void dispose() {
    super.dispose();
    _channel.dispose();
    _username.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Join Channel"),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10, top: 30, left: 20, right: 20),
            child: TextField(
              controller: _channel,
              autocorrect: false,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)),
                  hintText: "Enter channel name"),
            ),
          ),
           Container(
            margin: EdgeInsets.only(bottom: 10, top: 10, left: 20, right: 20),
            child: TextField(
              controller: _username,
              autocorrect: false,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)),
                  hintText: "Enter your name"),
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: 10),
              child: RaisedButton(
                elevation: 10,
                color: Colors.blue,
                child: Text(
                  "Join",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  if (_channel.text.isNotEmpty&&_username.text.isNotEmpty) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CallWindowStateful(_channel.text,_username.text)));
                  }
                },
              ))
        ],
      ),
    );
  }
}
