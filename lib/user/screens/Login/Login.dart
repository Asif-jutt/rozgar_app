import 'package:flutter/material.dart';
import 'package:rozgar/user/widgets/drawer.dart';
class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text("CNIC Number", style: TextStyle(fontSize: 16.0)),
            TextField(
              decoration: InputDecoration(
                hintText: "Enter your CNIC number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),

            SizedBox(height: 15),

            Text("Enter Email", style: TextStyle(fontSize: 16.0)),
            TextField(
              decoration: InputDecoration(
                hintText: "Enter your email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),

            SizedBox(height: 15),

            Text("Enter Password", style: TextStyle(fontSize: 16.0)),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Enter your password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),

            SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // login logic
                },
                child: Text("Login"),
              ),
            ),
          ],
        ),
      ),
      drawer: DrawerWidget(),
    );
  }
}