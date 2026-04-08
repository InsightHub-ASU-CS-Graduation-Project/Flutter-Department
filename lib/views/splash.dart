import 'package:flutter/material.dart';
import 'package:insight_hub/constant/routes.dart';
import 'package:insight_hub/constant/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();

    // Detect theme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isDarkMode =
            MediaQuery.of(context).platformBrightness == Brightness.dark;
      });
    });

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Start animations
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
    });

    // Navigation (زي ما هو)
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.welcomeScreen);
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildStar() {
    return Icon(
      Icons.star,
      size: 12,
      color: _isDarkMode ? Colors.blue[400] : Colors.blue[300],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isDarkMode
                ? [Colors.grey[900]!, Colors.grey[800]!]
                : [AppColors.bgLightBlue, AppColors.bgWhite],
          ),
        ),
        child: Stack(
          children: [
            // ⭐ النجوم (ثابتة وموزعة بشكل متوازن)
            Positioned(top: 80, left: 40, child: _buildStar()),
            Positioned(top: 150, right: 60, child: _buildStar()),
            Positioned(top: 250, left: 30, child: _buildStar()),
            Positioned(top: 350, right: 40, child: _buildStar()),
            Positioned(bottom: 200, left: 50, child: _buildStar()),
            Positioned(bottom: 120, right: 70, child: _buildStar()),

            // Main Content
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        margin: const EdgeInsets.only(bottom: 32),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.trending_up,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),

                      // Brand Name
                      Text(
                        "InsightHub",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode
                              ? Colors.white
                              : AppColors.textDark,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Tagline
                      Text(
                        "Your gateway to market intelligence",
                        style: TextStyle(
                          fontSize: 16,
                          color: _isDarkMode
                              ? Colors.grey[400]
                              : AppColors.textGray,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 48),

                      // ✨ Shimmer Loading Text
                      Shimmer.fromColors(
                        baseColor: _isDarkMode
                            ? Colors.grey[700]!
                            : Colors.grey[300]!,
                        highlightColor: _isDarkMode
                            ? Colors.grey[500]!
                            : Colors.white,
                        child: Text(
                          "Loading",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isDarkMode
                                ? Colors.white
                                : AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Branding
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  "Powered by Data Intelligence",
                  style: TextStyle(
                    fontSize: 12,
                    color: _isDarkMode
                        ? Colors.grey[600]
                        : Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}