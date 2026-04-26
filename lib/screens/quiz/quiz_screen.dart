import 'package:flutter/material.dart';
import 'package:flutter_app/router/app_router.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:flutter_app/utils/res/app_strings.dart';
import 'package:flutter_app/widgets/lumen_app_bar.dart';
import 'package:flutter_app/widgets/lumen_button.dart';
import 'package:flutter_app/widgets/lumen_card.dart';
import 'package:flutter_app/widgets/lumen_progress_bar.dart';
import 'package:flutter_app/widgets/lumen_quiz_option.dart';
import 'package:go_router/go_router.dart';

class QuizScreen extends StatefulWidget {
  final int step;
  const QuizScreen({super.key, required this.step});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? _singleChoice;
  final Set<int> _multiChoice = {};
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  final TextEditingController _birthLocation = TextEditingController();

  @override
  void dispose() {
    _birthLocation.dispose();
    super.dispose();
  }

  void _continue() {
    final next = _nextStep(widget.step);
    if (next == null) {
      context.go(AppRoutes.cosmic);
    } else {
      context.push('${AppRoutes.quiz}/$next');
    }
  }

  int? _nextStep(int current) {
    const seq = [1, 3, 5, 8];
    final idx = seq.indexOf(current);
    if (idx < 0 || idx == seq.length - 1) return null;
    return seq[idx + 1];
  }

  int _stepIndex() {
    const seq = [1, 3, 5, 8];
    final idx = seq.indexOf(widget.step);
    return idx < 0 ? 1 : idx + 1;
  }

  @override
  Widget build(BuildContext context) {
    // Pre-seed Quiz 1 with "Woman" and Quiz 3 with first two like the mockup
    if (widget.step == 1) _singleChoice ??= 0;
    if (widget.step == 3 && _multiChoice.isEmpty) {
      _multiChoice.addAll([0, 1]);
    }

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            LumenAppBar(
              showBack: true,
              titleWidget: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LumenProgressBar(currentStep: _stepIndex() + 1, totalSteps: 5),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildContent(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: LumenButton(
                label: AppStrings.quizContinue,
                onPressed: _continue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.step) {
      case 1:
        return _quizSingle(AppStrings.quiz1Question, AppStrings.quiz1Options);
      case 3:
        return _quizMulti(
          AppStrings.quiz3Question,
          AppStrings.quiz3Subtext,
          AppStrings.quiz3Options,
          maxSelect: 3,
        );
      case 5:
        return _quizDateTime();
      case 8:
        return _quizLocation();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _quizSingle(String question, List<String> options) {
    return ListView(
      children: [
        const SizedBox(height: 24),
        Text(question,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center),
        const SizedBox(height: 32),
        ...List.generate(options.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LumenQuizOption(
              label: options[i],
              selected: _singleChoice == i,
              onTap: () => setState(() => _singleChoice = i),
            ),
          );
        }),
      ],
    );
  }

  Widget _quizMulti(String question, String subtext, List<String> options,
      {int maxSelect = 3}) {
    return ListView(
      children: [
        const SizedBox(height: 24),
        Text(question,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(subtext,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center),
        const SizedBox(height: 28),
        ...List.generate(options.length, (i) {
          final selected = _multiChoice.contains(i);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LumenQuizOption(
              label: options[i],
              selected: selected,
              multiSelect: true,
              onTap: () => setState(() {
                if (selected) {
                  _multiChoice.remove(i);
                } else if (_multiChoice.length < maxSelect) {
                  _multiChoice.add(i);
                }
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _quizDateTime() {
    final dateLabel = _birthDate == null
        ? 'Tap to select'
        : '${_birthDate!.month}/${_birthDate!.day}/${_birthDate!.year}';
    final timeLabel = _birthTime == null
        ? 'Tap to select'
        : _birthTime!.format(context);
    return ListView(
      children: [
        const SizedBox(height: 24),
        Text(AppStrings.quiz5Question,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(AppStrings.quiz5Subtext,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center),
        const SizedBox(height: 28),
        _pickerTile(
          label: AppStrings.quiz5DateLabel,
          value: dateLabel,
          icon: Icons.calendar_today_outlined,
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(1995, 3, 14),
              firstDate: DateTime(1900),
              lastDate: now,
            );
            if (picked != null) setState(() => _birthDate = picked);
          },
        ),
        const SizedBox(height: 12),
        _pickerTile(
          label: AppStrings.quiz5TimeLabel,
          value: timeLabel,
          icon: Icons.access_time,
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: const TimeOfDay(hour: 4, minute: 32),
            );
            if (picked != null) setState(() => _birthTime = picked);
          },
        ),
      ],
    );
  }

  Widget _quizLocation() {
    return ListView(
      children: [
        const SizedBox(height: 24),
        Text(AppStrings.quiz8Question,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(AppStrings.quiz8Subtext,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center),
        const SizedBox(height: 28),
        LumenCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: _birthLocation,
            decoration: InputDecoration(
              hintText: AppStrings.quiz8Hint,
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              prefixIcon: const Icon(Icons.place_outlined,
                  color: AppColors.accentPurple, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _pickerTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return LumenCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentPurple, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
