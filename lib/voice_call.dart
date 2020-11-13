import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_channel.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RTCLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RTCRemoteView;
import 'package:permission_handler/permission_handler.dart';
import 'dart:collection';

class CallWindowStateful extends StatefulWidget {
  _CallWindowState createState() => _CallWindowState();
  final String channel_name, user_name;

  CallWindowStateful(this.channel_name, this.user_name);
}

class _CallWindowState extends State<CallWindowStateful> {
  bool _joined = false;
  int _remoteuid = null;
  int _localUid = null;
  bool _muted = false;
  String msg = "Please wait until you are connected";
  static const APP_ID = "28fd6c08aab04e2ba0786c92365bfd80";
  HashMap userID = HashMap<int, String>();
  RtcEngine engine;

  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    await Permission.microphone.request();

    engine = await RtcEngine.create(APP_ID);
    await engine.registerLocalUserAccount(APP_ID, widget.user_name);
    engine.setEventHandler(RtcEngineEventHandler(
      error: (err) {
        msg = err.toString();
        print(err);
      },
      localUserRegistered: (uid, userAccount) {
        setState(() {
          userID.putIfAbsent(uid, () => userAccount);
          _joined = true;
          _localUid = uid;
        });
      },
      userInfoUpdated: (uid, userInfo) {
        setState(() {
          userID.putIfAbsent(uid, () => userInfo.userAccount);
          _remoteuid = uid;
        });
      },
      userJoined: (uid, elapsed) {
        setState(() {
          _remoteuid = uid;
          userID.putIfAbsent(uid, () => "$uid");
        });
      },  
      userOffline: (uid, reason) {
        print("User $uid Offline because $reason");
        setState(() {
          _remoteuid = null;
          userID.remove(uid);
        });
      },
    ));

    await engine.joinChannelWithUserAccount(
        null, widget.channel_name, widget.user_name);
  }

  void dispose() {
    engine.leaveChannel();
    engine.destroy();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: AppBar(
              title: Text("Channel : ${widget.channel_name}"),
            ),
            body: userTiles(),
            bottomNavigationBar:
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                margin: EdgeInsets.all(20),
                child: RawMaterialButton(
                  padding: EdgeInsets.all(10),
                  fillColor: Colors.blue[900],
                  shape: CircleBorder(),
                  child: Icon(
                    _muted ? Icons.mic_off : Icons.mic,
                    size: 40,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _muted = !_muted;
                      engine.muteLocalAudioStream(_muted);
                    });
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.all(20),
                child: RawMaterialButton(
                  padding: EdgeInsets.all(10),
                  shape: CircleBorder(),
                  fillColor: Colors.red,
                  child: Icon(
                    Icons.call_end,
                    size: 40,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    engine.leaveChannel();
                    Navigator.pop(context);
                  },
                ),
              ),
            ])));
  }

  Widget userTiles() {
    if (_joined) {
      List<int> uidList = userID.keys.toList();
      return GridView.builder(
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemCount: userID.length,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.center,
              color: Colors.blue[300],
              child: Text(
                "${userID[uidList[index]]} is Connected",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            );
          });
    } else {
      return Text(msg);
    }
  }
}
