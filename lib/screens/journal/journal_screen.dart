import 'package:flutter/material.dart';
import 'package:flutter_app/data/mock_data.dart';
import 'package:flutter_app/models/lumen_models.dart';
import 'package:flutter_app/router/app_router.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:flutter_app/utils/res/app_strings.dart';
import 'package:flutter_app/widgets/lumen_chip.dart';
import 'package:go_router/go_router.dart';

enum JournalFilter { all, week, month }

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  JournalFilter _filter = JournalFilter.all;

  @override
  Widget build(BuildContext context) {
    final dreams = MockData.dreams;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(AppStrings.journalTitle,
                  style: Theme.of(context).textTheme.displayMedium),
            ),
            _iconBtn(Icons.search, () {}),
            const SizedBox(width: 8),
            _iconBtn(Icons.tune, () => context.push(AppRoutes.dreamPatterns)),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _filterTab(AppStrings.journalAll, JournalFilter.all),
            const SizedBox(width: 8),
            _filterTab(AppStrings.journalWeek, JournalFilter.week),
            const SizedBox(width: 8),
            _filterTab(AppStrings.journalMonth, JournalFilter.month),
          ],
        ),
        const SizedBox(height: 20),
        ...dreams.map((d) => _DreamTile(
              dream: d,
              onTap: () => context.push(AppRoutes.dreamInterpretation),
            )),
      ],
    );
  }

  Widget _filterTab(String label, JournalFilter f) {
    final active = _filter == f;
    const dur = Duration(milliseconds: 160);
    return AnimatedContainer(
      duration: dur,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: active ? AppColors.accentPurple : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? AppColors.accentPurple : AppColors.bgBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => setState(() => _filter = f),
          borderRadius: BorderRadius.circular(20),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.white.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: AnimatedDefaultTextStyle(
              duration: dur,
              curve: Curves.easeOut,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.bgDeep : AppColors.textSecondary,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.bgBorder),
          ),
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _DreamTile extends StatelessWidget {
  final Dream dream;
  final VoidCallback onTap;
  const _DreamTile({required this.dream, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 44,
                child: Column(
                  children: [
                    Text(dream.dateNumber,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontSize: 24,
                              color: AppColors.textPrimary,
                            )),
                    Text(dream.dateDay,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                width: 1,
                height: 64,
                color: AppColors.bgBorder,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dream.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontSize: 18,
                            )),
                    const SizedBox(height: 6),
                    Text(dream.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ...dream.typeTags.map((t) => LumenChip(
                              label: t,
                              selected: true,
                              tone: LumenChipTone.purple,
                              small: true,
                            )),
                        ...dream.emotionTags.map((t) => LumenChip(
                              label: t,
                              selected: true,
                              tone: LumenChipTone.gold,
                              small: true,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
