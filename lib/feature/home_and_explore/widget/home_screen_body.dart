import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insight_hub/core/constant/app_colors.dart';
import 'package:insight_hub/feature/home_and_explore/cubit/dashboard_cubit.dart';
import 'package:insight_hub/feature/home_and_explore/model/dashboard_item.dart';

import 'package:insight_hub/widget/app_header.dart';
import 'package:insight_hub/widget/app_motion.dart';
import 'package:insight_hub/feature/home_and_explore/widget/dashboard_item_card.dart';
import 'package:insight_hub/feature/home_and_explore/widget/safe_error_widget.dart';

class HomeScreenBody extends StatefulWidget {
  const HomeScreenBody({super.key});

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardCubit>().fetchHomeDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.bgGradient,
      ),
      child: SafeArea(
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return _buildLoadingState();
            }

            if (state is DashboardFailure) {
              return _buildErrorState(context, state.errorMessage);
            }

            if (state is DashboardSuccess) {
              if (state.items.isEmpty) {
                return _buildEmptyState();
              }
              return _buildSuccessState(state.items);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Column(
      children: [
        const AppHeader(
          title: 'Home',
          subtitle: 'Overview of your daily insights',
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SafeErrorWidget(
              message: errorMessage,
              onRetry: () =>
                  context.read<DashboardCubit>().fetchHomeDashboard(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const AppHeader(
          title: 'Home',
          subtitle: 'Overview of your daily insights and metrics',
        ),
        const Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'No analysis data available right now.',
                style: TextStyle(color: AppColors.textGray),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(List<DashboardItem> items) {
    final cardItems = items.where((item) => item.type == 'cards').toList();
    final otherItems = items.where((item) => item.type != 'cards').toList();

    return Column(
      children: [
        const AppHeader(
          title: 'Home',
          subtitle: 'Overview of your daily insights and metrics',
        ),
        Expanded(
          child: AppMotion(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              children: [
                ..._buildCardRows(cardItems),
                ..._buildOtherItems(otherItems),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCardRows(List<DashboardItem> cardItems) {
    return List.generate(
      (cardItems.length / 2).ceil(),
      (rowIndex) {
        final left = cardItems[rowIndex * 2];
        final rightIndex = rowIndex * 2 + 1;
        final hasRight = rightIndex < cardItems.length;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: DashboardItemCard(
                    item: left,
                    isCompact: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: hasRight
                      ? DashboardItemCard(
                          item: cardItems[rightIndex],
                          isCompact: true,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildOtherItems(List<DashboardItem> otherItems) {
    return otherItems
        .map((item) => Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: DashboardItemCard(
                item: item,
                isCompact: false,
              ),
            ))
        .toList();
  }
}