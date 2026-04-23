import 'package:flutter/material.dart';
import 'package:rozgar/pages/BuildProfile/BuildProfile.dart';
import 'package:rozgar/pages/Login/Login.dart';
import 'package:rozgar/pages/MyProfile/Myprofile.dart';
import 'package:rozgar/pages/Signup/Signup.dart';
import 'package:rozgar/pages/home/home.dart';
import 'package:rozgar/pages/MyApplication/Myapplication.dart';

void main(){
  runApp(Rozgar());
}

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