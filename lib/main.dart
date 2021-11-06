// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

// ignore: duplicate_ignore
class _HomeState extends State<Home> {
  // ignore: prefer_typing_uninitialized_variables
  var imagepath;
  var imageName;
  var downloadurl;
  ////////////////////// pick image////////////////////
  Future<void> pickimage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) {
      // ignore: avoid_print
      return print(image!.path);
    }

    // ignore: avoid_print

    imageName = path.basename(image.path);
    // ignore: avoid_print
    print(imageName);
    setState(() {
      imagepath = image.path;
      // ignore: avoid_print
      print(imagepath);
    });
  }

  ///
  ////// upload image function//////////////////////
  // ignore: non_constant_identifier_names
  Uploaddata() async {
    try {
      Map<String, dynamic> data = {
        "url": downloadurl,
        "title": "shahzad",
        "desc": "This is good boy"
      };
      firebase_storage.FirebaseStorage storage =
          firebase_storage.FirebaseStorage.instance;
      firebase_storage.Reference ref =
          firebase_storage.FirebaseStorage.instance.ref("/" + imageName);

      File file = File(imagepath);
      await ref.putFile(file);

      downloadurl = await ref.getDownloadURL();
      if (downloadurl != null) {
        FirebaseFirestore db = FirebaseFirestore.instance;
        await db.collection("post").add(data);
      }

      // ignore: avoid_print
      print("image uploaded succesfully" + "\n" + "$downloadurl");
    } catch (e) {
      // ignore: avoid_print
      print("Errrrror" + e.toString());
    }
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("post").snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot post = snapshot.data!.docs[index];
              if (snapshot.hasData) {
                return Material(
                  child: ListTile(
                    leading: Image.network(
                      post["url"],
                      height: 200,
                      width: 100,
                      fit: BoxFit.fitHeight,
                    ),
                    title: Text(post["title"]),
                    subtitle: Text(post["desc"]),
                    trailing: Column(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                pickimage();
                               setState(() {
                                   imageName = null;
                                  imagepath = null;
                               });
                              },
                              child: const Text("pick image")),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                Uploaddata();
                                setState(() {
                                  imageName = null;
                                  imagepath = null;
                                });
                              },
                              child: const Text("upload")),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const Center(
                child: Text("No Data"),
              );
            },
          );
        },
      ),
    );
  }
}
