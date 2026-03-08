import 'package:flutter/material.dart';
import 'package:insight_hub/views/email_registter.dart';
import 'package:insight_hub/views/sign_in.dart';
import 'package:insight_hub/widget/logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
//make routname for welcome screen
  static const String routeName = '/welcomeScreen';
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
              Color(0xffEFF6FF), // blue-50
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                // Icon Circle
                CustomLogo(),

                // Title
                const Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff111827),
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                const Text(
                  "Let's get started",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xff6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 60),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterEmailScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Continue",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Login Text Button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Already have an account? Log in",
                    style: TextStyle(
                      color: Color(0xff2563EB),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
