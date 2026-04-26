import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/router/app_router.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:flutter_app/utils/res/app_strings.dart';
import 'package:flutter_app/widgets/lumen_app_bar.dart';
import 'package:flutter_app/widgets/lumen_button.dart';
import 'package:flutter_app/widgets/lumen_card.dart';
import 'package:flutter_app/widgets/lumen_chip.dart';
import 'package:go_router/go_router.dart';

class DreamEntryScreen extends StatefulWidget {
  const DreamEntryScreen({super.key});

  @override
  State<DreamEntryScreen> createState() => _DreamEntryScreenState();
}

class _DreamEntryScreenState extends State<DreamEntryScreen>
    with SingleTickerProviderStateMixin {
  bool _recording = false;
  int _seconds = 0;
  Timer? _timer;
  late final AnimationController _pulse;

  final Set<int> _typeTags = {1, 3}; // Recurring, Vivid pre-selected
  final Set<int> _emotionTags = {0}; // Peaceful pre-selected

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  void _toggleRecord() {
    setState(() => _recording = !_recording);
    if (_recording) {
      _pulse.repeat(reverse: true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _seconds++);
      });
    } else {
      _pulse.stop();
      _timer?.cancel();
    }
  }

  String _timerLabel() {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            LumenAppBar(
              showBack: true,
              titleWidget: Text('Mar 14, 5:32 AM',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                children: [
                  const SizedBox(height: 16),
                  Center(child: _micRing()),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      _timerLabel(),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontSize: 36,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      _recording
                          ? AppStrings.entryRecording
                          : 'Tap the mic to begin',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: _recording
                                ? AppColors.accentPurple
                                : AppColors.textTertiary,
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  LumenCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TRANSCRIPT',
                            style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 10),
                        Text(
                          _recording || _seconds > 0
                              ? 'I was walking through my grandmother\'s house, but every door opened into another room I\'d never seen. The hallways kept going. I wasn\'t scared — I was curious.'
                              : AppStrings.entryTranscriptHint,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: _recording || _seconds > 0
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                                fontSize: 15,
                                height: 1.55,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      AppStrings.entryTypeTags.length,
                      (i) => LumenChip(
                        label: AppStrings.entryTypeTags[i],
                        selected: _typeTags.contains(i),
                        tone: LumenChipTone.purple,
                        onTap: () => setState(() {
                          _typeTags.contains(i)
                              ? _typeTags.remove(i)
                              : _typeTags.add(i);
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      AppStrings.entryEmotionTags.length,
                      (i) => LumenChip(
                        label: AppStrings.entryEmotionTags[i],
                        selected: _emotionTags.contains(i),
                        tone: LumenChipTone.gold,
                        onTap: () => setState(() {
                          _emotionTags.contains(i)
                              ? _emotionTags.remove(i)
                              : _emotionTags.add(i);
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: LumenButton(
                label: AppStrings.entryInterpret,
                leadingIcon: Icons.auto_awesome,
                onPressed: () => context.push(AppRoutes.dreamInterpretation),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _micRing() {
    return GestureDetector(
      onTap: _toggleRecord,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) {
          final scale = 1 + (_recording ? _pulse.value * 0.08 : 0.0);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 128,
              height: 128,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accentPurple.withValues(
                      alpha: 0.35 + (_recording ? _pulse.value * 0.25 : 0)),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPurple.withValues(
                        alpha: 0.25 + (_recording ? _pulse.value * 0.25 : 0)),
                    blurRadius: 40,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.avatarGradient,
                ),
                child: Icon(
                  _recording ? Icons.stop : Icons.mic,
                  color: AppColors.bgDeep,
                  size: 32,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
