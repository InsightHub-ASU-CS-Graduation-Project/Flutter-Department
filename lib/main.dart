import 'package:flutter/material.dart';
import 'package:insight_hub/views/welcome.dart';
import 'package:insight_hub/views/sign_in.dart';
import 'package:insight_hub/views/email_registter.dart';
import 'package:insight_hub/views/passowrd_regisster.dart';
import 'package:insight_hub/views/personal_one.dart';
import 'package:insight_hub/views/personal_two.dart';
import 'package:insight_hub/views/labor_information.dart';
import 'package:insight_hub/views/favorit.dart';
import 'package:insight_hub/views/confirmation.dart';
import 'package:insight_hub/constant/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Insight Hub',
      home: const WelcomeScreen(),
      routes: {
        Routes.welcomeScreen: (_) => const WelcomeScreen(),
        Routes.signInScreen: (_) => const SignInScreen(),
        Routes.registerEmailScreen: (_) => const RegisterEmailScreen(),
        Routes.registerPasswordScreen: (_) => const RegisterPasswordScreen(),
        Routes.registerNameScreen: (_) => const RegisterNameScreen(),
        Routes.registerEducationScreen: (_) => const RegisterEducationScreen(),
        Routes.laborInformationScreen: (_) => const LaborInformationScreen(),
        Routes.interestSelectionScreen: (_) => const InterestSelectionScreen(),
        Routes.confirmationScreen: (_) =>  ConfirmationScreen(
          firstName: '',
          interests: [],
        ),
      },
    );
  }
}
