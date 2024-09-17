import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

          if (snapshot.hasData) {
            final data = snapshot.data!.docs;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (ctx, item) {
                return ListTile(
                  onTap: () {},
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
                      fit: BoxFit.fill,
                    ),
                  ),
                  title: Text(data[item].data()["user_name"]),
                  subtitle: const Text("New Message"),
                );
              },
            );
          }

          return const Center(
            child: Text(
              "Ready to make your chats more fun?\ninvite your crew now!",
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}
