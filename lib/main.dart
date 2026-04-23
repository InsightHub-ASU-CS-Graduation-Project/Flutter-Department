import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insight_hub/cuibt/cubit/logout_cubit.dart';
import 'package:insight_hub/cuibt/cubit/profile_cubit.dart';
import 'package:insight_hub/services/api_service.dart';
import 'package:insight_hub/services/secure_storege.dart';
import 'package:insight_hub/views/onboarding.dart';
import 'package:insight_hub/views/welcome.dart';
import 'package:insight_hub/views/sign_in.dart';
import 'package:insight_hub/views/register/email_registter.dart';
import 'package:insight_hub/views/register/passowrd_regisster.dart';
import 'package:insight_hub/views/register/personal_one.dart';
import 'package:insight_hub/views/register/personal_two.dart';
import 'package:insight_hub/views/register/labor_information.dart';
import 'package:insight_hub/views/register/confirmation.dart';
import 'package:insight_hub/views/splash.dart';
import 'package:insight_hub/views/home_screen.dart';
import 'package:insight_hub/views/profile.dart';
import 'package:insight_hub/views/question_screen.dart';
import 'package:insight_hub/views/match_screen.dart';
import 'package:insight_hub/views/survey_menu_screen.dart';
import 'package:insight_hub/constant/routes.dart';
import 'package:insight_hub/cuibt/cubit/login_cubit.dart';
import 'package:insight_hub/cuibt/cubit/match_cubit.dart';
import 'package:insight_hub/cuibt/cubit/question_cubit.dart';
import 'package:insight_hub/cuibt/cubit/register_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SecureStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    ApiService.unauthorizedNotifier.addListener(_handleUnauthorized);
  }

  @override
  void dispose() {
    ApiService.unauthorizedNotifier.removeListener(_handleUnauthorized);
    super.dispose();
  }

  void _handleUnauthorized() {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushNamedAndRemoveUntil(
      Routes.signInScreen,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => RegisterCubit()),
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(create: (context) => LogoutCubit()),
        BlocProvider(create: (context) => ProfileCubit()),
        BlocProvider(create: (context) => MatchCubit()),
        BlocProvider(create: (context) => QuestionCubit()),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Insight Hub',
        home: const SplashScreen(),
        routes: {
          Routes.onboardingScreen: (_) => const OnboardingScreen(),
          Routes.welcomeScreen: (_) => const WelcomeScreen(),
          Routes.homeScreen: (_) => const HomeScreen(),
          Routes.signInScreen: (_) => const SignInScreen(),
          Routes.registerEmailScreen: (_) => const RegisterEmailScreen(),
          Routes.registerPasswordScreen: (_) => const RegisterPasswordScreen(),
          Routes.registerNameScreen: (_) => const RegisterNameScreen(),
          Routes.registerEducationScreen: (_) => const RegisterEducationScreen(),
          Routes.laborInformationScreen: (_) => const LaborInformationScreen(),
          Routes.confirmationScreen: (_) => ConfirmationScreen(),
          Routes.questionScreen: (_) => const QuestionScreen(),
          Routes.matchScreen: (_) => const MatchScreen(),
          Routes.profileScreen: (_) => const ProfileScreen(),
          Routes.surveyMenuScreen: (_) => const SurveyMenuScreen(),
        },
      ),
    );
  }
}
