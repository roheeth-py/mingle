import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message/screens/chat_screen.dart';

import '../profile_screen.dart';

class ChatListWidget extends StatelessWidget {
  const ChatListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("mingle."),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: const Text("Profile"),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) {
                          return const ProfilePage();
                        },
                      ),
                    );
                  },
                ),
                PopupMenuItem(
                  child: const Text("Logout"),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                ),
              ];
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection("users").get(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.length<=1) {
            return const Center(
              child: Text(
                "Ready to make your chats more fun?\ninvite your crew now!",
                textAlign: TextAlign.center,
              ),
            );
          }

          final docs = snapshot.data!.docs;
          final data = docs
              .where((e) =>
          FirebaseAuth.instance.currentUser!.uid != e.data()["user_id"])
              .toList();

          return ListView.separated(
            itemCount: data.length,
            itemBuilder: (ctx, item) {
              return ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => ChatScreen(data[item].data()),
                    ),
                  );
                },
                leading: Container(
                  height: 55,
                  width: 55,
                  clipBehavior: Clip.hardEdge,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Image.network(
                    data[item].data()["image_url"],
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(data[item].data()["user_name"]),
                subtitle: const Text("New Message"),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(
                indent: 20,
                endIndent: 20,
              );
            },
          );
        },
      ),
    );
  }
}