import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:insight_hub/constant/routes.dart';
import 'package:insight_hub/constant/app_colors.dart';
import 'package:insight_hub/widget/card_container.dart';

class LaborInformationScreen extends StatefulWidget {
  const LaborInformationScreen({super.key});

  static const String routeName = '/laborInformationScreen';

  @override
  State<LaborInformationScreen> createState() => _LaborInformationScreenState();
}

class _LaborInformationScreenState extends State<LaborInformationScreen> {

  int? selectedJob;
  int? selectedExperience;

  final List<Map<String, dynamic>> jobs = [
    {"id": 1, "name": "Software Developer"},
    {"id": 2, "name": "Designer"},
    {"id": 3, "name": "Marketing Specialist"},
    {"id": 4, "name": "Engineer"},
    {"id": 5, "name": "Business Analyst"},
    {"id": 6, "name": "Product Manager"}
  ];

  final List<Map<String, dynamic>> experienceYears = [
    {"value": 1, "text": "0 - 1 years"},
    {"value": 2, "text": "1 - 3 years"},
    {"value": 3, "text": "3 - 5 years"},
    {"value": 5, "text": "5 - 10 years"},
    {"value": 10, "text": "10+ years"}
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

              CardContainer(
                children: [

                  /// JOBS
                  const Text(
                    "Jobs to follow",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<int>(
                    value: selectedJob,
                    decoration: InputDecoration(
                      hintText: "Select job",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: jobs.map((job) {
                      return DropdownMenuItem<int>(
                        value: job["id"],
                        child: Text(job["name"]),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedJob = value;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  /// EXPERIENCE
                  const Text(
                    "Years of experience",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<int>(
                    value: selectedExperience,
                    decoration: InputDecoration(
                      hintText: "Select years",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: experienceYears.map((year) {
                      return DropdownMenuItem<int>(
                        value: year["value"],
                        child: Text(year["text"]),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedExperience = value;
                      });
                    },
                  ),
                ],
              ),

              const Spacer(),

              /// NEXT BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isValid
                      ? () {

                          Navigator.pushNamed(
                            context,
                            Routes.interestSelectionScreen,
                            arguments: {
                              "jobId": selectedJob,
                              "yearsExperience": selectedExperience,
                            },
                          );

                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
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
}