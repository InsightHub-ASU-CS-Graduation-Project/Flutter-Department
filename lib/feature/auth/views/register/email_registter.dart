import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:InsightHub/core/constant/routes.dart';
import 'package:InsightHub/feature/auth/cubit/register_cubit.dart';
import 'package:InsightHub/feature/auth/widget/auth_input_decoration.dart';
import 'package:InsightHub/feature/auth/widget/auth_layout.dart';
import 'package:InsightHub/feature/auth/widget/bottom_action_button.dart';
import 'package:InsightHub/feature/auth/widget/card_container.dart';
import 'package:InsightHub/feature/auth/widget/validatores.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RegisterAccountScreen extends StatefulWidget {
  const RegisterAccountScreen({super.key});

  static const String routeName = '/registerAccountScreen';

  @override
  State<RegisterAccountScreen> createState() => _RegisterAccountScreenState();
}

class _RegisterAccountScreenState extends State<RegisterAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  bool get _canProceed {
    return Validators.email(_emailController.text) == null &&
        Validators.strongPassword(_passwordController.text) == null &&
        _passwordController.text == _confirmController.text &&
        _confirmController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    context.read<RegisterCubit>().saveEmail(_emailController.text.trim());
    context.read<RegisterCubit>().savePassword(_passwordController.text);
    Navigator.pushNamed(context, Routes.registerNameScreen);
  }

  String? _confirmValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password confirmation is required';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create Account',
      subtitle: 'Enter your email, password, and confirm to continue.',
      action: BottomActionButton(
        label: 'Next',
        enabled: _canProceed,
        onPressed: _canProceed ? _handleNext : null,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardContainer(
              children: [
                const Text(' Email address'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r"\s")),
                  ],
                  decoration: authInputDecoration('you@example.com'),
                  validator: Validators.email,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                const Text('Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: authInputDecoration(
                    'Enter password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? LucideIcons.eye : LucideIcons.eyeOff,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  validator: Validators.strongPassword,
                  onChanged: (_) => setState(() {}),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 12),
                  child: Text(
                    'Min 8 characters, at least one number, one uppercase letter and one special character.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const Text('Confirm Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmController,
                  obscureText: !_showConfirmPassword,
                  decoration: authInputDecoration(
                    'Confirm password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword
                            ? LucideIcons.eye
                            : LucideIcons.eyeOff,
                        size: 20,
                      ),
                      onPressed: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword,
                      ),
                    ),
                  ),
                  validator: _confirmValidator,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
