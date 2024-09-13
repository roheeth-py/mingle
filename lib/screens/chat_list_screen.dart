import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message/screens/auth_screens/login_screen.dart';
import 'package:message/screens/profile_screen.dart';

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
          // Check if snapshot has data and ensure the data map exists

          if (!snapshot.hasData || snapshot.data!.data()==null) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }


          if(snapshot.data ==null || snapshot.data!.data()==null){
            return Login();
          }

          if (snapshot.hasError) {
            return const Scaffold(
                body: Center(child: Text("Failed To Retrieve Data")));
          }

          // If the user's 'user_name' field is null, show RegistrationPage
          if (snapshot.data!.data()!["user_name"] == null) {
            return const RegistrationPage();
          }

          // If everything is fine, show the chat list
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
        title: const Text("mingle."),
        actions: [
          PopupMenuButton(
              icon: const Icon(Icons.more_horiz),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: const Text("Profile"),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (ctx) {
                        return const ProfilePage();
                      }));
                    },
                  ),
                  PopupMenuItem(
                      child: const Text("Logout"),
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                      }),
                ];
              })
        ],
      ),
      body: const Center(
        child: Text("Chat List page"),
      ),
    );
  }
}