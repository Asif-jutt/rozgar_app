import 'package:flutter/material.dart';
import 'package:rozgar/user/screens/BuildProfile/BuildProfile.dart';
import 'package:rozgar/user/screens/Login/Login.dart';
import 'package:rozgar/user/screens/MyProfile/Myprofile.dart';
import 'package:rozgar/user/screens/Signup/Signup.dart';
import 'package:rozgar/user/screens/home/home.dart';
import 'package:rozgar/user/screens/MyApplication/Myapplication.dart';



class Rozgar extends StatelessWidget {
  const Rozgar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,

      ),
      home: Home(),
      routes: {
        '/home': (context) => Home(),
        '/Login': (context) => Login(),
        '/Signup': (context) => Signup(),
        '/buildprofile': (context) => Buildprofile(),
        '/myprofile': (context) => Myprofile(),
        '/myapplication': (context) => Myapplication(),
      },
         );
  }
}