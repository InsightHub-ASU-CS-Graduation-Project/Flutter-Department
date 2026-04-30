import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insight_hub/constant/app_colors.dart';
import 'package:insight_hub/cuibt/cubit/profile_cubit.dart';

import 'package:insight_hub/views/profile.dart';
import 'package:insight_hub/views/search_screen.dart';
import 'package:insight_hub/views/survey_menu_screen.dart';
import 'package:insight_hub/widget/bottom_nav.dart';
import 'package:insight_hub/widget/home_screen_body.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/homeScreen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGray,
      body:widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar:Container(
        decoration: 
            BoxDecoration(
                color:   Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black.withOpacity(.1),
                  ),
                ],
              )
            ,
        child:  MainNavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              )
           
      )
    );
  }
}
final List<Widget> widgetOptions = <Widget>[
  const HomeScreenBody(),
  const SearchScreen(),
  SurveyMenuScreen(),
  const ProfileScreen(),
];