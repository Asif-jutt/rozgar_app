import 'package:flutter/material.dart';
import 'package:rozgar/user/models/job_model.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onCardPressed;
  final VoidCallback? onApplyPressed;

  const JobCard({
    super.key,
    required this.job,
    this.onCardPressed,
    this.onApplyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------- JOB IMAGE WITH FALLBACK --------
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                job.image,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Text(
                        "Image not available",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // -------- JOB TITLE --------
            Text(
              job.jobTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            // -------- COMPANY NAME --------
            Text(
              job.companyName,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),

            const SizedBox(height: 10),

            // -------- SALARY + LOCATION --------
            Row(
              children: [
                _buildChip(Icons.payments, job.salary),
                const SizedBox(width: 5),
                _buildChip(Icons.location_on, job.location),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DESCRIPTION
                Text(
                  "Description:",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  job.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                // SKILLS
                Text(
                  "Required Skills:",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),

                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: job.requiredSkills.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            // const Spacer(), // it pushes remaining item to the bottom of the cart
            const SizedBox(height: 8),

            // -------- APPLY BUTTON --------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onApplyPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text("Apply Now"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------- CHIP BUILDER --------
  Widget _buildChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.blue),
          const SizedBox(width: 3),
          Text(text, style: const TextStyle(fontSize: 11, color: Colors.blue)),
        ],
      ),
    );
  }
}
