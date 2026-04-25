import 'package:flutter/material.dart';

class UserBody extends StatelessWidget {
  const UserBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ElevatedButton(
              onPressed: () {},
              child: const Text('View All Jobs'),
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Manage Company'),
                ),

                const SizedBox(width: 20),

                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Manage Applicants'),
                ),
              ],
            ),
          ],
        ),
      );

  }
}