import 'dart:io';
import 'package:chatapp/ui/widgets/play_voice_screen.dart';
import 'package:chatapp/ui/widgets/show_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatefulWidget {
  Map<String, dynamic>? userMap;
  String? chatRoomId;

  ChatRoom({required this.chatRoomId, required this.userMap});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? imageFile;

//select image
  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker
        .pickImage(source: ImageSource.gallery, imageQuality: 30)
        .then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  //for creating unique file name
  String fileName = Uuid().v1();
  //upload image in storage & save into firestore
  Future uploadImage() async {
    int status = 1;

    await _firestore
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });
    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();
      status = 0;
    });
    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});
      // print(imageUrl);
      //first message will be create userList collection
      await _firestore.collection('userlist').doc(widget.userMap!['email']).set(
          {'email': widget.userMap!['email'], 'name': widget.userMap!['name']});
    }
  }

  //send text message
  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(messages);

      //first message will be create userList collection
      await _firestore.collection('userlist').doc(widget.userMap!['email']).set(
          {'email': widget.userMap!['email'], 'name': widget.userMap!['name']});
    } else {
      print("Enter Some Text");
    }
  }

  //instance for voice message
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;
  String? musicUrl;

  @override
  void initState() {
    initRecorder();
    super.initState();
  }

  //dispose recorder
  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

//permission & open recorder
  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Permisson status not granted';
    }
    await recorder.openRecorder();

    isRecorderReady = true;
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

//start record
  Future record() async {
    if (!isRecorderReady) return;
    await recorder.startRecorder(toFile: 'audio');
  }

//stop record & upload this record
  Future stop() async {
    if (!isRecorderReady) return;
    final path = await recorder.stopRecorder();
    final audioFile = File(path!);
    // print('Record Studio ${audioFile}');

    int status = 1;

    await _firestore
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "type": "mp3",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('voice').child("$fileName.mp3");
    var uploadTask = await ref
        .putFile(audioFile, SettableMetadata(contentType: 'mp3'))
        .catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();
      status = 0;
    });
    if (status == 1) {
      String voiceUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": voiceUrl});

      musicUrl = voiceUrl;
      // print(voiceUrl);

      //first message will be create userList collection
      await _firestore.collection('userlist').doc(widget.userMap!['email']).set(
          {'email': widget.userMap!['email'], 'name': widget.userMap!['name']});
    }
  }

  @override
  Widget build(BuildContext context) {
    //mediaquery size
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        //reciever name
        title: widget.userMap!['uid'] == null
            //when user chats 2nd time
            ? StreamBuilder<DocumentSnapshot>(
                stream: _firestore
                    .collection("userlist")
                    .doc(widget.userMap!['email'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Text(widget.userMap!['name']);
                  } else {
                    return Container();
                  }
                },
              )
            //when user chats 1st time
            : StreamBuilder<DocumentSnapshot>(
                stream: _firestore
                    .collection("users")
                    .doc(widget.userMap!['uid'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Text(widget.userMap!['name']);
                  } else {
                    return Container();
                  }
                },
              ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              //all msg show up part
              Container(
                height: size.height / 1.25,
                width: size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('chatroom')
                      .doc(widget.chatRoomId)
                      .collection('chats')
                      .orderBy("time", descending: false)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.data != null) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> map = snapshot.data!.docs[index]
                              .data() as Map<String, dynamic>;
                          return Align(
                              alignment: Alignment.bottomCenter,
                              child: messages(size, map, context));
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              //msg textfield part
              Container(
                height: size.height / 10,
                width: size.width,
                alignment: Alignment.center,
                child: SizedBox(
                  height: size.height / 12,
                  width: size.width / 1.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: size.height / 17,
                        width: size.width / 1.3,
                        child: TextField(
                          controller: _message,
                          decoration: InputDecoration(
                              //for send image
                              suffixIcon: IconButton(
                                onPressed: () => getImage(),
                                icon: const Icon(Icons.photo),
                              ),
                              //for send voice
                              prefixIcon: IconButton(
                                onPressed: () async {
                                  if (recorder.isRecording) {
                                    await stop();
                                  } else {
                                    await record();
                                  }
                                  setState(() {});
                                },
                                icon: Icon(recorder.isRecording
                                    ? Icons.stop
                                    : Icons.mic),
                              ),
                              hintText: "Send Message",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              )),
                        ),
                      ),
                      IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: onSendMessage),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    return map['type'] == 'text'
        //text message ui
        ? Container(
            width: size.width,
            alignment: map['sendby'] == _auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.blue,
              ),
              child: Text(
                map['message'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          )
        : map['type'] == 'mp3'
            //voice message ui
            ? Container(
                width: size.width,
                alignment: map['sendby'] == _auth.currentUser!.displayName
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: InkWell(
                  //listen voice
                  onTap: () => Get.to(PlayVoiceScreen(map['message'])),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 14),
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.blue,
                      ),
                      child: const Text(".........")),
                ),
              )
            //image message ui
            : Container(
                height: size.height / 2.5,
                width: size.width,
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                alignment: map['sendby'] == _auth.currentUser!.displayName
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ShowImage(
                        imageUrl: map['message'],
                      ),
                    ),
                  ),
                  child: Container(
                    height: size.height / 2.5,
                    width: size.width / 2,
                    decoration: BoxDecoration(border: Border.all()),
                    alignment: map['message'] != "" ? null : Alignment.center,
                    child: map['message'] != ""
                        ? Image.network(
                            map['message'],
                            fit: BoxFit.cover,
                          )
                        : const CircularProgressIndicator(),
                  ),
                ));
  }
}
