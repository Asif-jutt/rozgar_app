import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.work),
          label: 'Post Jobs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Messages',
        ),
      ],
      currentIndex: 0,
      selectedItemColor: const Color.fromARGB(255, 157, 160, 163),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if(index==0){
          // Navigate to Home
          Navigator.pushNamed(context, "/home");
        } else if(index==1){
          // Navigate to Post Jobs
          Navigator.pushNamed(context, "/post-jobs");
        } else if(index==2){
          // Navigate to Messages
          Navigator.pushNamed(context, "/messages");
        }
      },
    );
  }
}