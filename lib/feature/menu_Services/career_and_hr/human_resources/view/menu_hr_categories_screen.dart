import 'package:flutter/material.dart';
import 'package:insight_hub/core/constant/app_colors.dart';
import 'package:insight_hub/feature/menu_Services/career_and_hr/human_resources/view/question_hr_screen.dart';
import 'package:insight_hub/feature/menu_Services/widget/card_services.dart';
import 'package:insight_hub/widget/app_header.dart';

class MenuHrCategoriesScreen extends StatelessWidget {
  const MenuHrCategoriesScreen({super.key});

  static const String routeName = '/menuHrCategoriesScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              const AppHeader(
                title: 'Human Resources',
                subtitle: 'Choose a category to start the interview quiz.',
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: categoriesHr.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final category = categoriesHr[index];

                    return buildSurveyCard(
                      context,
                      title: category.name,
                      subtitle:
                          'Practice ${category.name} interview questions.',
                      icon: category.icon,
                      isActive: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => QuestionHrScreen(
                              categoryName: category.name,
                              apiCategory: category.apiValue,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final List<Category> categoriesHr = [
  Category(name: 'Backend', apiValue: 'Backend', icon: Icons.storage),
  Category(name: 'Frontend', apiValue: 'Frontend', icon: Icons.web),
  Category(name: 'Q/A Testing', apiValue: 'Q/A Testing', icon: Icons.bug_report),
  Category(
    name: 'Data Analysis',
    apiValue: 'Data Analysis',
    icon: Icons.bar_chart,
  ),
  Category(name: 'AI/ML', apiValue: 'AI/ML', icon: Icons.smart_toy),
  Category(name: 'Mobile', apiValue: 'Mobile', icon: Icons.phone_android),
  Category(name: 'Embedded', apiValue: 'Embedded', icon: Icons.memory),
  Category(name: 'Game', apiValue: 'Game Dev', icon: Icons.sports_esports),
  Category(
    name: 'Cybersecurity',
    apiValue: 'Cybersecurity',
    icon: Icons.security,
  ),
];

class Category {
  final String name;
  final String apiValue;
  final IconData icon;

  const Category({
    required this.name,
    required this.apiValue,
    required this.icon,
  });
}
