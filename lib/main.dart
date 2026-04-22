import 'package:flutter/material.dart';

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
    );
  }
}