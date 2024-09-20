import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class ChatScreen extends StatefulWidget {
  const ChatScreen(this.data, {super.key});

  final Map<String, dynamic> data;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> method() async {
    List ids = [
      FirebaseAuth.instance.currentUser!.uid.toString(),
      widget.data["user_id"].toString()
    ];
    ids.sort();
    String chatId = ids.join();

    final doc =
        await FirebaseFirestore.instance.collection("chats").doc(chatId).get();
    if (doc.exists) return;
    await FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
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
    List ids = [
      FirebaseAuth.instance.currentUser!.uid.toString(),
      widget.data["user_id"].toString()
    ];
    ids.sort();
    String chatId = ids.join();
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        actions: [
          Container(
            height: 40,
            width: 40,
            clipBehavior: Clip.hardEdge,
            decoration: const ShapeDecoration(shape: CircleBorder()),
            child: Image.network(widget.data["image_url"], fit: BoxFit.fill,),
          ),
          const SizedBox(width: 15,),
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
            if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              const Center(child: Text("Error Occured, Try after some time"));
            }

            List f = snapshot.data!.data()!["messages"];
            if (f.isEmpty && snapshot.hasData) {
              return const Center(child: Text("Spark the Conversation Now!"));
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 65, top: 10),
              child: ListView.builder(
                  itemCount: f.length,
                  itemBuilder: (ctx, item) {
                    return Row(
                      mainAxisAlignment:
                          (FirebaseAuth.instance.currentUser!.uid !=
                                  f[item]["sender_id"])
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          margin:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: (FirebaseAuth.instance.currentUser!.uid !=
                                  f[item]["sender_id"])
                                  ? const Color(0xFF007AFF)
                                  : Colors.grey[300]),
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Text(f[item]["text"].toString(), style: TextStyle(
                            color:  (FirebaseAuth.instance.currentUser!.uid !=
                                f[item]["sender_id"])
                                ? Colors.white
                                :Colors.black,
                            fontSize: 16
                          ),),
                        ),
                      ],
                    );
                  }),
            );
          }),
      bottomSheet: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: Stack(
          children: [
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
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
                      .doc(chatId)
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
