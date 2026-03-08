import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ConfirmationScreen extends StatelessWidget {
  final String firstName;
  final List<String> interests;
//make routname
  static const String routeName = '/confirmationScreen';
  // Icon Map equivalent to your iconMap
  final Map<String, IconData> iconMap = {
    'technology': LucideIcons.code,
    'health': LucideIcons.heart,
    'business': LucideIcons.briefcase,
    'design': LucideIcons.palette,
    'energy': LucideIcons.zap,
    'engineering': LucideIcons.cpu,
    'marketing': LucideIcons.trendingUp,
    'hr': LucideIcons.users,
  };

  // Title Map equivalent to your titleMap
  final Map<String, String> titleMap = {
    'technology': 'Technology',
    'health': 'Health',
    'business': 'Business',
    'design': 'Design',
    'energy': 'Energy',
    'engineering': 'Engineering',
    'marketing': 'Marketing',
    'hr': 'Human Resources',
  };

   ConfirmationScreen({
    super.key,
    required this.firstName,
    required this.interests,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0FDF4), // green-50
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Success Icon
              const Icon(
                LucideIcons.checkCircle,
                size: 96,
                color: Color(0xFF16A34A), // green-600
              ),
              
              const SizedBox(height: 32),
              
              const Text(
                "You're All Set!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                "Welcome to InsightHub, $firstName!",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Color(0xFF4B5563)),
              ),
              
              const SizedBox(height: 32),

              // Interests Card
              if (interests.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your Selected Interests",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...interests.map((key) => _buildInterestRow(key)).toList(),
                    ],
                  ),
                ),

              const Spacer(),

              // Home Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB), // blue-600
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Go to Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterestRow(String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE), // blue-100
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              iconMap[key] ?? LucideIcons.helpCircle,
              size: 20,
              color: const Color(0xFF2563EB), // blue-600
            ),
          ),
          const SizedBox(width: 12),
          Text(
            titleMap[key] ?? key,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
