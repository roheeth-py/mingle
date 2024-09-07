import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_screens/registration_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.data!.data()!["user_name"] == null) {
            return const RegistrationPage();
          }
          return const ChatListWidget();
        });
  }
}

class ChatListWidget extends StatelessWidget {
  const ChatListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("mingle."),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_horiz),
              itemBuilder: (context){
            return [
              PopupMenuItem(child: Text("Settings")),
              PopupMenuItem(child: Text("Logout"),  onTap: () async {
                await FirebaseAuth.instance.signOut();
              }
                ),
            ];
          })
        ],
      ),
      body: Center(
        child: Text("chatlist page"),
      ),
    );
  }
}
