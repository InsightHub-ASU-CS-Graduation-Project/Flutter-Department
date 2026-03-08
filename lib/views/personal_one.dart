import 'package:flutter/material.dart';
import 'package:insight_hub/widget/card_container.dart';

import 'package:lucide_icons/lucide_icons.dart';
import 'package:insight_hub/constant/routes.dart';
import 'package:insight_hub/constant/app_colors.dart';

class RegisterNameScreen extends StatefulWidget {
  const RegisterNameScreen({super.key});
//make routname
  static const String routeName = '/registerNameScreen';
  @override
  State<RegisterNameScreen> createState() => _RegisterNameScreenState();
}

class _RegisterNameScreenState extends State<RegisterNameScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _selectedGender;

  bool get _isValid =>
      _firstNameController.text.trim().isNotEmpty &&
      _lastNameController.text.trim().isNotEmpty &&
      _selectedGender != null;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
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

      body: SafeArea(
        child: Column(
          children: [

            /// SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const SizedBox(height: 10),

                      const Text(
                        'Personal Info',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Tell us your name and gender',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 32),

                      /// NAME CARD
                      CardContainer(children: [
                        _label("First Name"),
                        _textField(_firstNameController, "John"),
                        const SizedBox(height: 16),
                        _label("Last Name"),
                        _textField(_lastNameController, "Doe"),
                      ]),

                      const SizedBox(height: 16),

                      /// GENDER CARD
                      CardContainer(children: [
                        _label("Gender"),
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: _inputDecoration("Select gender"),
                          items: ['Male', 'Female']
                              .map(
                                (val) => DropdownMenuItem(
                                  value: val,
                                  child: Text(val),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedGender = val),
                        ),
                      ]),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            /// FIXED BUTTON
            Padding(
              padding: const EdgeInsets.all(24),
              child: _nextButton(
                onPressed: _isValid
                    ? () => Navigator.pushNamed(context, Routes.registerEducationScreen)
                    : null,
                label: "Next",
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// LABEL
  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textDarkGray,
          ),
        ),
      );

  /// INPUT DECORATION
  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
      );

  /// TEXT FIELD
  Widget _textField(TextEditingController controller, String hint) =>
      TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        decoration: _inputDecoration(hint),
      );

  /// NEXT BUTTON
  Widget _nextButton({
    required String label,
    VoidCallback? onPressed,
  }) =>
      SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor:  AppColors.primaryBlue,
            disabledBackgroundColor:  AppColors.disabledButton,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
}

