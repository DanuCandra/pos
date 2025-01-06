import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pos_kasir/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Danu Cafe POS',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Home(checkoutItems: []),
      debugShowCheckedModeBanner: false,
    );
  }
}
