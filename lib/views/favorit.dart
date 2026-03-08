import 'package:flutter/material.dart';
import 'package:insight_hub/views/confirmation.dart';
import 'package:lucide_icons/lucide_icons.dart';

class InterestSelectionScreen extends StatefulWidget {
  const InterestSelectionScreen({super.key});
 //make routname
  static const String routeName = '/interestSelectionScreen';
  @override
  State<InterestSelectionScreen> createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  // Track selected IDs
  final Set<String> _selectedInterests = {};

  final List<Map<String, dynamic>> _categories = [
    {'id': 'technology', 'label': 'Technology', 'icon': LucideIcons.code},
    {'id': 'health', 'label': 'Health', 'icon': LucideIcons.heart},
    {'id': 'business', 'label': 'Business', 'icon': LucideIcons.briefcase},
    {'id': 'design', 'label': 'Design', 'icon': LucideIcons.palette},
    {'id': 'energy', 'label': 'Energy', 'icon': LucideIcons.zap},
    {'id': 'engineering', 'label': 'Engineering', 'icon': LucideIcons.cpu},
    {'id': 'marketing', 'label': 'Marketing', 'icon': LucideIcons.trendingUp},
    {'id': 'hr', 'label': 'Human Resources', 'icon': LucideIcons.users},
  ];

  void _toggleInterest(String id) {
    setState(() {
      if (_selectedInterests.contains(id)) {
        _selectedInterests.remove(id);
      } else {
        _selectedInterests.add(id);
      }
    });
  }

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What interests you?",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select at least one to continue",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // GRID OF INTERESTS
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final item = _categories[index];
                  final isSelected = _selectedInterests.contains(item['id']);

                  return GestureDetector(
                    onTap: () => _toggleInterest(item['id']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFDBEAFE) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['icon'],
                            color: isSelected ? const Color(0xFF2563EB) : Colors.black54,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['label'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? const Color(0xFF2563EB) : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // NEXT BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedInterests.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConfirmationScreen(
                                firstName: "John", // Replace with real data
                                interests: _selectedInterests.toList(),
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}