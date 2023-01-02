import 'package:chatapp/logic/auth.dart';
import 'package:chatapp/ui/views/chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? userMap;

  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//craete chatroom id for different 2 users
  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

//search all validate users
  void onSearch() async {
    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("email", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      // print(userMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        actions: [
          //for user logout
          ElevatedButton(
              onPressed: () {
                Auth().signOut();
              },
              child: const Text("Logout"))
        ],
      ),
      body: isLoading
          ? Center(
              child: SizedBox(
                height: size.height / 20,
                width: size.height / 20,
                child: const CircularProgressIndicator(),
              ),
            )
          : Column(
              children: [
                //search textfield ui
                Container(
                  height: size.height / 14,
                  width: size.width,
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: size.height / 14,
                    width: size.width / 1.15,
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        hintText: "Search",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 50,
                ),
                ElevatedButton(
                  onPressed: onSearch,
                  child: const Text("Search"),
                ),
                SizedBox(
                  height: size.height / 30,
                ),
                //matching user name & email data
                userMap != null
                    ? ListTile(
                        onTap: () {
                          String roomId = chatRoomId(
                              _auth.currentUser!.displayName!,
                              userMap!['name']);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatRoom(
                                chatRoomId: roomId,
                                userMap: userMap!,
                              ),
                            ),
                          );
                        },
                        leading:
                            const Icon(Icons.account_box, color: Colors.black),
                        title: Text(
                          userMap!['name'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(userMap!['email']),
                        trailing: const Icon(Icons.chat, color: Colors.black),
                      )
                    : Container(),
                SizedBox(
                  height: size.height / 30,
                ),

                const Divider(
                  height: 2,
                  color: Colors.black,
                ),
                //already chat user list
                FutureBuilder(
                    future: _firestore.collection('userlist').get(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasError) {
                        return const Text("Error");
                      } else if (snapshot.hasData) {
                        var data = snapshot.data.docs;

                        return Expanded(
                          child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                var indexData = data![index];

                                Map<String, dynamic> data2 = indexData.data();
                                return ListTile(
                                  onTap: () {
                                    String roomId = chatRoomId(
                                        _auth.currentUser!.displayName!,
                                        indexData['name']);

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatRoom(
                                          chatRoomId: roomId,
                                          userMap: data2,
                                        ),
                                      ),
                                    );
                                  },
                                  leading: const Icon(Icons.account_box,
                                      color: Colors.black),
                                  title: Text(indexData['name']),
                                  subtitle: Text(indexData['email']),
                                  trailing: const Icon(Icons.chat,
                                      color: Colors.black),
                                );
                              }),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    })
              ],
            ),
    );
  }
}
