import 'package:flutter/material.dart';

import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:insight_hub/constant/routes.dart';
import 'package:insight_hub/constant/app_colors.dart';
import 'package:insight_hub/widget/card_container.dart';

class RegisterEducationScreen extends StatefulWidget {
  const RegisterEducationScreen({super.key});
   //make routname
  static const String routeName = '/registerEducationScreen';
  @override
  State<RegisterEducationScreen> createState() => _RegisterEducationScreenState();
}

class _RegisterEducationScreenState extends State<RegisterEducationScreen> {
  DateTime? _birthdate;
  final _collegeController = TextEditingController();
  bool _graduated = false;

  bool get _isValid => _birthdate != null && _collegeController.text.isNotEmpty;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthdate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Education', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Your academic background', style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 32),
        
              CardContainer(
                children: [
                  // Birthday Picker
                  const Text("Birthdate", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color:  AppColors.borderMedium),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _birthdate == null ? "Select date" : DateFormat('MMMM dd, yyyy').format(_birthdate!),
                            style: TextStyle(color: _birthdate == null ? Colors.grey : Colors.black),
                          ),
                          const Icon(LucideIcons.calendar, size: 20, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
          
                  const SizedBox(height: 24),
          
                  // College Input
                  const Text("College", style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _collegeController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "University name",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
        
              const SizedBox(height: 24),
        
              // Graduated Toggle
              SwitchListTile(
                title: const Text("I have graduated", style: TextStyle(fontWeight: FontWeight.w500)),
                value: _graduated,
                activeColor: Colors.blue,
                onChanged: (val) => setState(() => _graduated = val),
                contentPadding: EdgeInsets.zero,
              ),
        
          
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isValid ? () => Navigator.pushNamed(context, Routes.laborInformationScreen): null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Next', style: TextStyle(color: Colors.white, fontSize: 16)),
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