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
          // Check if snapshot has data and ensure the data map exists
          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.data() == null) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<DocumentSnapshot<Map<String, dynamic>>> getData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    return doc;
  }

  Future<String> get userImage async {
    var data = await getData();
    return data["user_image"];
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              child: FutureBuilder(
                  future: getData(),
                  builder: (ctx, snapshot) {
                    if (snapshot.hasData) {
                      return Image.network(
                        snapshot.data!.data()!["image_url"],
                        fit: BoxFit.cover,
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
            ),
            const SizedBox(
              height: 25,
            ),
            FutureBuilder(
                future: getData(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Text("Error occurred");
                  }
                  return Text(
                    snapshot.data!.data()!["user_name"],
                    style: const TextStyle(fontSize: 18),
                  );
                }),
            Divider(
              height: 60,
              indent: 20,
              endIndent: 20,
            ),
            SwitchListTile(
              value: false,
              onChanged: (value) {},
              title: Text("Dark Mode"),
              subtitle:
                  Text("We are working to release it in future versions."),
            ),
            Spacer(),
            Text("© Roheeth Dhanasekaran"),
            SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }
}
