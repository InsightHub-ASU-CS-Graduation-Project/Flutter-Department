import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insight_hub/constant/app_colors.dart';
import 'package:insight_hub/constant/routes.dart';
import 'package:insight_hub/cuibt/cubit/match_cubit.dart';
import 'package:insight_hub/cuibt/cubit/profile_cubit.dart';
import 'package:insight_hub/cuibt/cubit/question_cubit.dart';
import 'package:insight_hub/model/match_model.dart';
import 'package:insight_hub/model/profile_model.dart';
import 'package:insight_hub/model/question_model.dart';
import 'package:insight_hub/widget/bottom_nav.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:insight_hub/widget/app_header.dart';
import 'package:insight_hub/widget/app_motion.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  static const String routeName = '/questionScreen';

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int _currentIndex = 0;
  bool _requestedQuestions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final profileState = context.read<ProfileCubit>().state;
      if (profileState is ProfileSuccess) {
        _loadQuestions(profileState.profile);
      } else {
        context.read<ProfileCubit>().fetchProfile();
      }
    });
  }

  void _loadQuestions(ProfileModel profile) {
    print("QuestionScreen: _loadQuestions triggered (isEmployed: ${profile.isEmployed}), requested: $_requestedQuestions");
    if (_requestedQuestions) {
      return;
    }

    setState(() {
      _currentIndex = 0;
    });
    _requestedQuestions = true;
    context.read<QuestionCubit>().fetchQuestions(isEmployed: profile.isEmployed);
  }

  void _retry() {
    setState(() {
      _currentIndex = 0;
    });
    _requestedQuestions = false;
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is ProfileSuccess) {
      _loadQuestions(profileState.profile);
      return;
    }

    context.read<ProfileCubit>().fetchProfile();
  }

  void _goToNext(int lastIndex) {
    if (_currentIndex >= lastIndex) {
      return;
    }

    setState(() {
      _currentIndex += 1;
    });
  }

  void _goToPrevious() {
    if (_currentIndex == 0) {
      return;
    }

    setState(() {
      _currentIndex -= 1;
    });
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Survey?'),
            content: const Text(
              'Your progress will be lost. Are you sure you want to leave?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Exit',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileSuccess) {
              _loadQuestions(state.profile);
            } else if (state is ProfileFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
        BlocListener<QuestionCubit, QuestionState>(
          listener: (context, state) {
            if (state is QuestionLoaded && state.didSubmitSucceed) {
              if (state.isEmployed) {
                // Employed users: skip match API, show thank-you
                Navigator.pushReplacementNamed(
                  context,
                  Routes.surveyThankYouScreen,
                );
              } else {
                // Unemployed users: Use the result from submission and show match result
                context.read<MatchCubit>().reset();
                if (state.submissionResult != null) {
                  context.read<MatchCubit>().emitResult(state.submissionResult!);
                }
                Navigator.pushReplacementNamed(context, Routes.matchScreen);
              }
            }
          },
        ),
      ],
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldPop = await _showExitConfirmation(context);
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF6F8FC),
          body: SafeArea(
            child: BlocBuilder<QuestionCubit, QuestionState>(
              builder: (context, questionState) {
                final profileState = context.watch<ProfileCubit>().state;

                if (profileState is ProfileLoading && !_requestedQuestions) {
                  return const _QuestionLoadingView();
                }

                if (profileState is ProfileFailure && !_requestedQuestions) {
                  return _QuestionErrorView(
                    message: profileState.message,
                    onRetry: _retry,
                  );
                }

                if (questionState is QuestionLoading) {
                  return const _QuestionLoadingView();
                }

                if (questionState is QuestionError) {
                  return _QuestionErrorView(
                    message: questionState.message,
                    onRetry: _retry,
                  );
                }

                if (questionState is! QuestionLoaded) {
                  return const SizedBox.shrink();
                }

                final questions = questionState.questions;
                final currentQuestion = questions[_currentIndex];
                final progress = (_currentIndex + 1) / questions.length;
                final isCurrentAnswered = questionState.isAnswered(
                  currentQuestion.id,
                );
                final isLastQuestion = _currentIndex == questions.length - 1;

                return Column(
                  children: [
                    AppHeader(
                      title: 'Question Flow',
                      subtitle: 'Answer a few quick questions so we can personalize your experience.',
                      showBackButton: true,
                      leadingIcon: Icons.close,
                      onBackPress: () async {
                        final shouldPop = await _showExitConfirmation(context);
                        if (shouldPop && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      extra: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFBFDBFE),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Question ${_currentIndex + 1} of ${questions.length}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.92),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: AppMotion(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Column(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 320),
                                transitionBuilder: (child, animation) {
                                  final curved = CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  );

                                  return FadeTransition(
                                    opacity: curved,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.08, 0),
                                        end: Offset.zero,
                                      ).animate(curved),
                                      child: child,
                                    ),
                                  );
                                },
                                child: _QuestionCard(
                                  key: ValueKey(currentQuestion.id),
                                  question: currentQuestion,
                                  answer: questionState.answers[currentQuestion.id],
                                  onChanged: (value) {
                                    context.read<QuestionCubit>().answerQuestion(
                                      currentQuestion.id,
                                      value,
                                    );
                                  },
                                ),
                              ),
                              if ((questionState.validationMessage ?? '')
                                  .isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFFFECACA),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          LucideIcons.alertCircle,
                                          color: Color(0xFFDC2626),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            questionState.validationMessage!,
                                            style: const TextStyle(
                                              color: Color(0xFFB91C1C),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _currentIndex == 0
                                  ? null
                                  : _goToPrevious,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Previous'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: questionState.isSubmitting
                                  ? null
                                  : isLastQuestion
                                  ? (isCurrentAnswered
                                        ? () => context
                                              .read<QuestionCubit>()
                                              .submitAnswers()
                                        : null)
                                  : (isCurrentAnswered
                                        ? () => _goToNext(questions.length - 1)
                                        : null),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: questionState.isSubmitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(isLastQuestion ? 'Submit' : 'Next'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QuestionModel question;
  final dynamic answer;
  final ValueChanged<int> onChanged;

  const _QuestionCard({
    super.key,
    required this.question,
    required this.answer,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _getTypeLabel(),
              style: const TextStyle(
                color: Color(0xFF1D4ED8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            question.text,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          _buildInput(),
        ],
      ),
    );
  }

  String _getTypeLabel() {
    switch (question.type) {
      case QuestionType.choice:
        return 'Choice';
      case QuestionType.scale:
        return 'Scale 1-5';
      case QuestionType.yesNo:
        return 'Yes/No';
    }
  }

  Widget _buildInput() {
    switch (question.type) {
      case QuestionType.choice:
        if (question.options.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No options available.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }
        return Column(
          children: question.options
              .map(
                (option) => _ChoiceTile(
                  text: option.text,
                  value: option.numericValue,
                  groupValue: answer is int ? answer : null,
                  onSelected: onChanged,
                ),
              )
              .toList(),
        );
      case QuestionType.scale:
        return _ScaleInput(
          value: answer is int ? answer : null,
          onChanged: onChanged,
        );
      case QuestionType.yesNo:
        return _YesNoInput(
          value: answer is int ? answer : null,
          onChanged: onChanged,
        );
    }
  }
}

class _ChoiceTile extends StatelessWidget {
  final String text;
  final int value;
  final int? groupValue;
  final ValueChanged<int> onSelected;

  const _ChoiceTile({
    required this.text,
    required this.value,
    required this.groupValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onSelected(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Radio<int>(
                value: value,
                groupValue: groupValue,
                onChanged: (v) {
                  if (v != null) {
                    onSelected(v);
                  }
                },
                activeColor: AppColors.primaryBlue,
              ),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YesNoInput extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;

  const _YesNoInput({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _YesNoButton(
            label: 'Yes',
            isSelected: value == 1,
            onTap: () => onChanged(1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _YesNoButton(
            label: 'No',
            isSelected: value == 0,
            onTap: () => onChanged(0),
          ),
        ),
      ],
    );
  }
}

class _YesNoButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _YesNoButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primaryBlue : const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScaleInput extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;

  const _ScaleInput({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final currentValue = (value ?? 3).toDouble();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value == null
                ? 'Move the slider to choose a value.'
                : 'Selected value: $value',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryBlue,
              thumbColor: AppColors.primaryBlue,
              overlayColor: AppColors.primaryBlue.withOpacity(0.16),
              inactiveTrackColor: const Color(0xFFCBD5E1),
            ),
            child: Slider(
              min: 1,
              max: 5,
              divisions: 4,
              value: currentValue,
              label: value?.toString() ?? currentValue.round().toString(),
              onChanged: (newValue) => onChanged(newValue.round()),
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1', style: TextStyle(color: Color(0xFF64748B))),
              Text('2', style: TextStyle(color: Color(0xFF64748B))),
              Text('3', style: TextStyle(color: Color(0xFF64748B))),
              Text('4', style: TextStyle(color: Color(0xFF64748B))),
              Text('5', style: TextStyle(color: Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestionLoadingView extends StatelessWidget {
  const _QuestionLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _QuestionErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _QuestionErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.alertTriangle,
              size: 40,
              color: Color(0xFFDC2626),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
