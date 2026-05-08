import 'package:flutter/material.dart';
import 'package:insight_hub/feature/home_and_explore/cubit/dashboard_cubit.dart';
import 'package:insight_hub/feature/home_and_explore/widget/dashboard_items_view.dart';
import 'package:insight_hub/feature/home_and_explore/widget/safe_error_widget.dart';

class DashboardStateView extends StatelessWidget {
  const DashboardStateView({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onRetry,
    this.initial,
    this.emptyMessage = 'No analysis data available right now.',
  });

  final DashboardState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final Widget? initial;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (state is DashboardInitial) {
      return initial ?? _buildLoadingState();
    }

    if (state is DashboardLoading) {
      return _buildLoadingState();
    }

    if (state is DashboardFailure) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SafeErrorWidget(
          message: (state as DashboardFailure).errorMessage,
          onRetry: onRetry,
        ),
      );
    }

    if (state is DashboardSuccess) {
      return DashboardItemsView(
        items: (state as DashboardSuccess).items,
        onRefresh: onRefresh,
        emptyMessage: emptyMessage,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }
}
