import 'package:flutter/material.dart';

class Myapplication extends StatelessWidget {
  const Myapplication({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Text("My Applications"),
          Row(
            // crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: 100,
                color: const Color.fromARGB(255, 224, 202, 200),
                child: Text("Application1"),
                alignment: Alignment.center,
              ),
              SizedBox(width: 20,),
              Container(
                height: 100,
                width: 100,
                color: const Color.fromARGB(255, 210, 190, 189),
                child: Text("Application2"),
                alignment: Alignment.center,
              ),
            ],
          ),
          SizedBox(height: 20,),
          Row(
            // crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: 100,
                color: const Color.fromARGB(255, 224, 202, 200),
                child: Text("Application1"),
                alignment: Alignment.center,
              ),
              SizedBox(width: 20,),
              Container(
                height: 100,
                width: 100,
                color: const Color.fromARGB(255, 210, 190, 189),
                child: Text("Application2"),
                alignment: Alignment.center,
              ),
            ],
          ),
          SizedBox(width: 20,),
        ],
      )
        
    );
  }
}