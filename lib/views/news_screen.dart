import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:insight_hub/constant/app_colors.dart';
import 'package:insight_hub/cuibt/cubit/news_cubit.dart';
import 'package:insight_hub/cuibt/cubit/news_state.dart';
import 'package:insight_hub/model/news_model.dart';
import 'package:insight_hub/widget/app_header.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  static const String routeName = '/newsScreen';

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<NewsCubit>().loadMore();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsCubit>().loadNews(reset: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGray,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'News',
            subtitle: 'Updated every 12 hours',
              showBackButton: true,
            ),

            // 🔥 CATEGORY BAR (Fixed)
            _buildCategoryBar(),

            const SizedBox(height: 10),

            Expanded(
              child: BlocBuilder<NewsCubit, NewsState>(
                builder: (context, state) {
                  if (state is NewsLoading) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  if (state is NewsError) {
                    return Center(child: Text(state.message));
                  }

                  if (state is NewsLoaded) {
                    if (state.newsList.isEmpty) {
                      return const Center(
                          child: Text('No news available'));
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: state.newsList.length +
                          (state.hasMorePages ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.newsList.length) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(
                                child: CircularProgressIndicator()),
                          );
                        }

                        return _buildCard(state.newsList[index]);
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CATEGORY BAR =================

  Widget _buildCategoryBar() {
    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        final cubit = context.read<NewsCubit>();
        final selected = cubit.selectedCategories;

        return Column(
          children: [
            // Title + Clear
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (selected.isNotEmpty)
                    TextButton(
                      onPressed: () => cubit.setCategories([]),
                      child: const Text('Clear All'),
                    ),
                ],
              ),
            ),

            // Categories List
            SizedBox(
              height: 50,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: NewsCubit.categories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = NewsCubit.categories[index];
                  final isSelected = selected.contains(category);

                  return GestureDetector(
                    onTap: () {
                      final updated =
                          List<String>.from(selected);

                      if (isSelected) {
                        updated.remove(category); // ✅ FIXED
                      } else {
                        updated.add(category);
                      }

                      cubit.setCategories(updated);
                    },
                    child: AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : Colors.grey.shade300,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.check,
                                size: 14,
                                color: Colors.white),
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= CARD =================

  Widget _buildCard(NewsModel news) {
    return GestureDetector(
      onTap: () {
        if (news.url != null && news.url!.isNotEmpty) {
          _openUrl(news.url!);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
              child: news.urlToImage != null
                  ? Image.network(
                      news.urlToImage!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _placeholder(),
                    )
                  : _placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                          LucideIcons.globe,
                          size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          news.sourceName ??
                              'Unknown',
                          style: const TextStyle(
                              fontSize: 12),
                        ),
                      ),
                      Text(
                        _formatDate(
                            news.publishedAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _placeholder() {
    return Container(
      height: 150,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(LucideIcons.image, size: 40),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';

    return DateFormat('MMM d').format(date);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri,
        mode: LaunchMode.externalApplication);
  }
}