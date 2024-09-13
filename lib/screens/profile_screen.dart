import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
        title: const Text("Settings"),
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
              child: GestureDetector(
                onTap: () async {
                  final img = await ImagePicker().pickImage(source: ImageSource.camera);
                  if(img==null) return ;
                  final imgPath = File(img.path);
                  final storageRef = FirebaseStorage.instance.ref("user_image").child("${FirebaseAuth.instance.currentUser!.uid}.jpg");
                  await storageRef.putFile(imgPath);
                  final url = await storageRef.getDownloadURL();

                  FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).update({
                    "image_url": url,
                  });
                },
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
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
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
