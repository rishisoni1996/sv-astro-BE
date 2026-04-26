import 'package:flutter/material.dart';
import 'package:flutter_app/utils/res/app_colors.dart';
import 'package:flutter_app/widgets/lumen_zodiac_glyph.dart';

class UserProfile {
  final String name;
  final String initials;
  final BirthChart birthChart;
  final int dreamCount;
  final String memberSince;
  final bool isPremium;
  final String premiumPlan;
  final String premiumRenews;

  UserProfile({
    required this.name,
    required this.initials,
    required this.birthChart,
    required this.dreamCount,
    required this.memberSince,
    required this.isPremium,
    required this.premiumPlan,
    required this.premiumRenews,
  });
}

class BirthChart {
  final ZodiacSign sun;
  final ZodiacSign moon;
  final ZodiacSign rising;
  final String date;
  final String time;
  final String location;

  BirthChart({
    required this.sun,
    required this.moon,
    required this.rising,
    required this.date,
    required this.time,
    required this.location,
  });
}

class Dream {
  final String id;
  final String title;
  final String content;
  final String dateNumber; // "14"
  final String dateDay;    // "Sun"
  final String timestamp;  // "5:32 AM"
  final List<String> typeTags;
  final List<String> emotionTags;
  final DreamInterpretation? interpretation;

  Dream({
    required this.id,
    required this.title,
    required this.content,
    required this.dateNumber,
    required this.dateDay,
    required this.timestamp,
    required this.typeTags,
    required this.emotionTags,
    this.interpretation,
  });
}

class DreamInterpretation {
  final String coreMeaning;
  final String whatReveals;
  final String guidance;
  final List<DreamSymbol> symbols;
  final bool isPremiumSection;

  DreamInterpretation({
    required this.coreMeaning,
    required this.whatReveals,
    required this.guidance,
    required this.symbols,
    this.isPremiumSection = false,
  });
}

class DreamSymbol {
  final String emoji;
  final String name;
  final int count;
  final String lastSeen;
  final Gradient? gradient;
  DreamSymbol({
    required this.emoji,
    required this.name,
    required this.count,
    required this.lastSeen,
    this.gradient,
  });
}

class TarotCard {
  final String numeral;
  final String name;
  final List<String> keywords;
  final String whatShows;
  final String appliesToToday;
  final String questionToCarry;
  final String deck;
  TarotCard({
    required this.numeral,
    required this.name,
    required this.keywords,
    required this.whatShows,
    required this.appliesToToday,
    required this.questionToCarry,
    required this.deck,
  });
}

class EmotionalTheme {
  final String label;
  final double percent;
  final Color color;
  EmotionalTheme({required this.label, required this.percent, required this.color});
}

class WeeklyPatterns {
  final List<DreamSymbol> recurringSymbols;
  final List<EmotionalTheme> themes;
  final String weeklySummary;
  WeeklyPatterns({
    required this.recurringSymbols,
    required this.themes,
    required this.weeklySummary,
  });
}

class SubscriptionPlan {
  final String id;
  final String title;
  final String price;
  final String unit;
  final String? badge;
  SubscriptionPlan({
    required this.id,
    required this.title,
    required this.price,
    required this.unit,
    this.badge,
  });
}

class SignReveal {
  final ZodiacSign sign;
  final String label;
  final String signName;
  final String description;
  final Gradient gradient;
  SignReveal({
    required this.sign,
    required this.label,
    required this.signName,
    required this.description,
    required this.gradient,
  });
}

// Common gradient helpers used by data layer
class LumenGradients {
  LumenGradients._();
  static const LinearGradient waterSymbol = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33458FFF), Color(0x1A458FFF)],
  );
  static const LinearGradient houseSymbol = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33FFD89E), Color(0x1AFFD89E)],
  );
  static const LinearGradient teethSymbol = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33FF8AC5), Color(0x1AFF8AC5)],
  );
  static const LinearGradient sunCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2B0F3A), Color(0xFF0B0B1A)],
  );
  static const LinearGradient moonCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F2A3A), Color(0xFF0B0B1A)],
  );
  static const LinearGradient risingCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3A210F), Color(0xFF0B0B1A)],
  );
}

class PatternColors {
  PatternColors._();
  static const Color anxious = AppColors.accentPurple;
  static const Color confused = AppColors.accentTeal;
  static const Color heavy = AppColors.accentGold;
  static const Color peaceful = Color(0xFF8B6BC4);
}
