import 'package:flutter/material.dart';

class Myprofile extends StatelessWidget {
  const Myprofile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("My Skills"),
          Row(
            // crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: 100,
                color: const Color.fromARGB(255, 224, 202, 200),
                child: Text("Skill1"),
                alignment: Alignment.center,
              ),
              SizedBox(width: 20,),
              Container(
                height: 100,
                width: 100,
                color: const Color.fromARGB(255, 210, 190, 189),
                child: Text("Skill2"),
                alignment: Alignment.center,
              ),
            ],
          ),
          Text("My Educations"),
          Row(
            // crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: 100,
                color: const Color.fromARGB(255, 224, 202, 200),
                child: Text("Education1"),
                alignment: Alignment.center,
              ),
              SizedBox(width: 20,),
              Container(
                height: 100,
                width: 100,
                color: const Color.fromARGB(255, 210, 190, 189),
                child: Text("Education2"),
                alignment: Alignment.center,
              ),
            ],
          ),
          Text("Other Info"),
          Row(
            // crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: 100,
                color: const Color.fromARGB(255, 224, 202, 200),
                child: Text("Info1"),
                alignment: Alignment.center,
              ),
              SizedBox(width: 20,),
              Container(
                height: 100,
                width: 100,
                color: const Color.fromARGB(255, 210, 190, 189),
                child: Text("Info2"),
                alignment: Alignment.center,
              ),
            ],
          )
        ],
      ),
    );
  }
}