import 'package:flutter/material.dart';
import 'package:rozgar/user/widgets/drawer.dart';

class Buildprofile extends StatelessWidget {
  const Buildprofile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Skills"),

              SizedBox(
                width: double.infinity, // full width
                child: DropdownButton<String>(
                  isExpanded: true, // IMPORTANT for full width
                  items: [
                    DropdownMenuItem(value: "flutter", child: Text("Flutter")),
                    DropdownMenuItem(value: "react", child: Text("React")),
                    DropdownMenuItem(value: "angular", child: Text("Angular")),
                  ],
                  onChanged: (value) {
                    // handle skill selection
                  },
                ),
              ),
              SizedBox(height: 20),
              Text("Enter Degrees"),
              TextField(
                decoration: InputDecoration(
                  hintText: "Enter your degrees",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text("Address"),
              TextField(
                decoration: InputDecoration(
                  hintText: "Enter your address",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text("Email"),

              TextField(
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              // Upload CV Button
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // handle CV upload
                },
                child: Text("Upload CV"),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // save profile logic
                  },
                  child: Text("Create"),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: DrawerWidget(),
    );
  }
}
