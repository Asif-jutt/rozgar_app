import 'package:flutter/material.dart';

class PostJobWidget extends StatelessWidget {
  PostJobWidget({super.key});

  final ValueNotifier<String> selectedDuration =
      ValueNotifier("Full Time");

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          // Job Title
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Enter Job Title",
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.work, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Requirements
          TextField(
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Enter Requirements",
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.description, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Budget
          TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Enter Budget",
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.attach_money, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Dropdown
          ValueListenableBuilder(
            valueListenable: selectedDuration,
            builder: (context, value, _) {
              return DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF1E1E1E),
                value: value,
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: "Full Time", child: Text("Full Time")),
                  DropdownMenuItem(value: "Part Time", child: Text("Part Time")),
                  DropdownMenuItem(value: "Remote", child: Text("Remote")),
                ],
                onChanged: (newValue) {
                  selectedDuration.value = newValue!;
                },
                decoration: InputDecoration(
                  labelText: "Job Duration",
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.access_time, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Job Posted Successfully")),
                );
              },
              child: const Text(
                "Post Job",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}