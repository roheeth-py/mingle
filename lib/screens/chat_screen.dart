import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

class ChatScreen extends StatefulWidget {
  const ChatScreen(this.data, {super.key});

  final Map<String, dynamic> data;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();

  Future<void> method() async {
    List ids = [FirebaseAuth.instance.currentUser!.uid.toString(), widget.data["user_id"].toString()];
    ids.sort();
    String chatId = ids.join();

    final doc = await FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId).get();
    if (doc.exists) return;
    await FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.data["user_id"].toString() +
            FirebaseAuth.instance.currentUser!.uid.toString())
        .set({
      "id": chatId,
      "messages": [],
      "participants": [
        widget.data["user_id"].toString(),
        FirebaseAuth.instance.currentUser!.uid.toString()
      ],
    });
  }

  @override
  void initState() {
    method();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List ids = [FirebaseAuth.instance.currentUser!.uid.toString(), widget.data["user_id"].toString()];
    ids.sort();
    String chatId = ids.join();
    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            height: 40,
            width: 40,
            clipBehavior: Clip.hardEdge,
            decoration: const ShapeDecoration(shape: CircleBorder()),
            child: Image.network(widget.data["image_url"]),
          ),
        ],
        titleSpacing: 8,
        title: Text(
          widget.data["user_name"].toString(),
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chats")
              .doc(chatId)
              .snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());

            if (snapshot.hasError) {
              Center(child: Text("Error Occured, Try after some time"));
            }

            List f = snapshot.data!.data()!["messages"];
            if (f.isEmpty && snapshot.hasData)
              return Center(child: Text("Spark the Conversation Now!"));

            return ListView.builder(itemCount: f.length, itemBuilder: (ctx, item){
              return Row(
                children: [
                  Container(
                    child: Text(f[item].toString()),
                  )
                ],
              );
            });
          }),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            TextField(
              controller: controller,
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                contentPadding: const EdgeInsets.only(
                  left: 25,
                  right: 50,
                  top: 10,
                  bottom: 10,
                ),
                hintText: 'Type your message...',
              ),
              minLines: 1,
              maxLines: 5,
            ),
            Positioned(
              right: 10,
              bottom: .01,
              child: IconButton(
                onPressed: () async {
                  if (controller.text.isEmpty) return;
                  await FirebaseFirestore.instance
                      .collection("chats")
                      .doc(widget.data["user_id"].toString() +
                          FirebaseAuth.instance.currentUser!.uid.toString())
                      .update({
                    "messages": FieldValue.arrayUnion([
                      {
                        "text": controller.text,
                        "sender_id": FirebaseAuth.instance.currentUser!.uid,
                        "timestamp": Timestamp.now(),
                      }
                    ]),
                  });
                 controller.clear();
                },
                icon: const Icon(Icons.send_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewMessage {
  NewMessage({required this.message});

  final String message;
}
