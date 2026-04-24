import 'package:flutter/material.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text("Home"),
              onTap: (){
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              title: Text("Login"),
              onTap: (){
                Navigator.pop(context);
                Navigator.pushNamed(context, '/Login');
              },
            ),
            ListTile(
              title: Text("Sign Up"),
              onTap: (){
                Navigator.pop(context);
                Navigator.pushNamed(context, '/Signup');
              },
            ),
            ListTile(
              title: Text("Build Profile"),
              onTap: (){
                Navigator.pop(context);
                Navigator.pushNamed(context, '/buildprofile');
              },
            ),
            ListTile(
              title: Text("My Profile"),
              onTap: (){
                Navigator.pop(context);
                Navigator.pushNamed(context, '/myprofile');
              },
            ),
            ListTile(
              title: Text("My Application"),
              onTap: (){
                Navigator.pop(context);
                Navigator.pushNamed(context, '/myapplication');
              },
            ),
          ],
        ),
      ),
    );
  }
}