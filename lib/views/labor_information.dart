import 'package:flutter/material.dart';
import 'package:insight_hub/views/favorit.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LaborInformationScreen extends StatefulWidget {
  const LaborInformationScreen({super.key});

  @override
  State<LaborInformationScreen> createState() => _LaborInformationScreenState();
}

class _LaborInformationScreenState extends State<LaborInformationScreen> {

  String? selectedJob;
  String? selectedExperience;

  final List<String> jobs = [
    "Software Developer",
    "Designer",
    "Marketing Specialist",
    "Engineer",
    "Business Analyst",
    "Product Manager"
  ];

  final List<String> experienceYears = [
    "0 - 1 years",
    "1 - 3 years",
    "3 - 5 years",
    "5 - 10 years",
    "10+ years"
  ];

  bool get isValid => selectedJob != null && selectedExperience != null;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10),

              const Text(
                "Labor Information",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Tell us about your job interests and experience",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 32),

              /// JOBS TO FOLLOW
              const Text(
                "Jobs to follow",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedJob,
                decoration: InputDecoration(
                  hintText: "Select job",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: jobs.map((job) {
                  return DropdownMenuItem(
                    value: job,
                    child: Text(job),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedJob = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              /// YEARS EXPERIENCE
              const Text(
                "Years of experience",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedExperience,
                decoration: InputDecoration(
                  hintText: "Select years",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: experienceYears.map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedExperience = value;
                  });
                },
              ),

              const Spacer(),

              /// NEXT BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isValid
                      ? () {
                        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const InterestSelectionScreen(),
          ),
        );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}//make continuo to this page  InterestSelectionScreen()