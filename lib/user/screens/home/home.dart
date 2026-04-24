import 'package:flutter/material.dart';
import 'package:rozgar/user/widgets/drawer.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rozgar"),
      ),
      drawer: DrawerWidget(),
      body: Column(
        
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // here we will be implementing the filters for jobs on the basis of Location, Sallary, and Skills
        
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search for jobs",
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),

          // Jobs Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2, // 2 per row
              padding: const EdgeInsets.all(16),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.4,
              children: [
                Card(
                  child: ListTile(
                    title: Text("Job1"),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text("Job2"),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text("Job3"),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text("Job4"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}