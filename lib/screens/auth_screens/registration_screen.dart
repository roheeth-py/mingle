import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final userName = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key
  File? userImage;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: screenHeight,
            width: screenWidth,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    "https://images.unsplash.com/photo-1663517768994-a65e6ab3a40a?q=80&w=1854&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              margin: EdgeInsets.only(
                top: screenHeight * 0.15,
                left: screenWidth * 0.05,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Create Profile",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Set a picture of yours, and add a unique username",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 40),
              height: screenHeight * .6,
              width: screenWidth,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () async {
                      final img = await ImagePicker().pickImage(
                          source: ImageSource.camera, imageQuality: 50);
                      if (img == null) return;
                      setState(() {
                        userImage = File(img.path);
                      });
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      clipBehavior: Clip.hardEdge,
                      decoration: const ShapeDecoration(shape: CircleBorder()),
                      child: (userImage == null)
                          ? Image.network(
                          "https://gts-ts.com/wp-content/uploads/2018/11/placeholder-person.png")
                          : Image.file(
                        userImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Form(
                    key: _formKey, // Use the form key here
                    child: TextFormField(
                      controller: userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(.7),
                      ),
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        hintText: "User Name",
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 3) {
                          return "Enter a valid User Name";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            if (userImage == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select an image")));
              return;
            }

            final currentUser = FirebaseAuth.instance.currentUser!;
            final storageRef = FirebaseStorage.instance
                .ref("user_image")
                .child("${currentUser.uid}.jpg");

            // Upload the image
            await storageRef.putFile(userImage!);
            final imageUrl = await storageRef.getDownloadURL();

            // Update Firestore with user data
            await FirebaseFirestore.instance
                .collection("users")
                .doc(currentUser.uid)
                .update({
              "user_name": userName.text,
              "image_url": imageUrl,
            });

            print(currentUser.uid);
          }
        },
        icon: const Icon(Icons.check_circle_outlined),
        label: const Text("Validate"),
      ),
    );
  }
}
