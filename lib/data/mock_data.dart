import 'package:flutter_app/models/lumen_models.dart';
import 'package:flutter_app/widgets/lumen_zodiac_glyph.dart';

class MockData {
  MockData._();

  static UserProfile currentUser = UserProfile(
    name: 'Maya',
    initials: 'M',
    birthChart: BirthChart(
      sun: ZodiacSign.scorpio,
      moon: ZodiacSign.cancer,
      rising: ZodiacSign.leo,
      date: 'Mar 14, 1995',
      time: '4:32 AM',
      location: 'Brooklyn, NY',
    ),
    dreamCount: 42,
    memberSince: 'Mar 2026',
    isPremium: true,
    premiumPlan: 'Premium · Annual',
    premiumRenews: 'Renews March 14, 2027',
  );

  static List<Dream> dreams = [
    Dream(
      id: 'd1',
      title: 'The house that kept unfolding',
      content:
          'I was walking through my grandmother\'s house, but every door opened into another room I\'d never seen. The hallways kept going. I wasn\'t scared — I was curious.',
      dateNumber: '14',
      dateDay: 'Sun',
      timestamp: '5:32 AM',
      typeTags: const ['Recurring', 'Vivid'],
      emotionTags: const ['Peaceful'],
      interpretation: DreamInterpretation(
        coreMeaning:
            'The expanding house is the psyche revealing itself to you. Each unfamiliar room is a part of you you haven\'t met yet.',
        whatReveals:
            'Curiosity, not fear, is guiding you deeper. That\'s rare — and a sign you\'re ready.',
        guidance:
            'Today, notice what you feel drawn to investigate. Follow it without needing to know why.',
        symbols: [
          DreamSymbol(emoji: '🏚️', name: 'Houses', count: 5, lastSeen: '2d ago',
              gradient: LumenGradients.houseSymbol),
          DreamSymbol(emoji: '🚪', name: 'Doors', count: 4, lastSeen: '2d ago',
              gradient: LumenGradients.waterSymbol),
        ],
      ),
    ),
    Dream(
      id: 'd2',
      title: 'Water that wouldn\'t recede',
      content:
          'The tide came all the way up to the porch. I kept waiting for it to pull back. It didn\'t.',
      dateNumber: '12',
      dateDay: 'Fri',
      timestamp: '6:04 AM',
      typeTags: const ['Recurring', 'Heavy'],
      emotionTags: const ['Anxious'],
    ),
    Dream(
      id: 'd3',
      title: 'Teeth falling into my hand',
      content:
          'One by one, with no pain. Just the quiet sound of them landing.',
      dateNumber: '10',
      dateDay: 'Wed',
      timestamp: '4:18 AM',
      typeTags: const ['Nightmare', 'Vivid'],
      emotionTags: const ['Anxious', 'Confused'],
    ),
    Dream(
      id: 'd4',
      title: 'A stranger calling my name',
      content:
          'I didn\'t recognize the voice, but it knew me. I kept turning and no one was there.',
      dateNumber: '8',
      dateDay: 'Mon',
      timestamp: '3:41 AM',
      typeTags: const ['Fragment'],
      emotionTags: const ['Confused'],
    ),
    Dream(
      id: 'd5',
      title: 'Flying just above the trees',
      content:
          'I could feel the air lift me. I wasn\'t trying. It just happened.',
      dateNumber: '6',
      dateDay: 'Sat',
      timestamp: '5:12 AM',
      typeTags: const ['Lucid'],
      emotionTags: const ['Inspired'],
    ),
  ];

  static TarotCard todaysCard = TarotCard(
    numeral: 'XVIII',
    name: 'The Moon',
    keywords: const ['INTUITION', 'DREAMS', 'ILLUSION'],
    whatShows:
        'The Moon is the card of the unseen. It speaks to what you sense before you can explain, what pulls at you before you understand why.',
    appliesToToday:
        'Your gut has been trying to tell you something about the week ahead. Today, stop asking for proof. Listen.',
    questionToCarry: 'What do I already know, even without the evidence?',
    deck: 'Celestial · 22 Major Arcana',
  );

  static WeeklyPatterns weeklyPatterns = WeeklyPatterns(
    recurringSymbols: [
      DreamSymbol(
        emoji: '🌊', name: 'Water', count: 7, lastSeen: 'Last night',
        gradient: LumenGradients.waterSymbol,
      ),
      DreamSymbol(
        emoji: '🏚️', name: 'Houses', count: 5, lastSeen: '2d ago',
        gradient: LumenGradients.houseSymbol,
      ),
      DreamSymbol(
        emoji: '🦷', name: 'Teeth', count: 3, lastSeen: '4d ago',
        gradient: LumenGradients.teethSymbol,
      ),
    ],
    themes: [
      EmotionalTheme(label: 'Anxious',  percent: 42, color: PatternColors.anxious),
      EmotionalTheme(label: 'Confused', percent: 28, color: PatternColors.confused),
      EmotionalTheme(label: 'Heavy',    percent: 18, color: PatternColors.heavy),
      EmotionalTheme(label: 'Peaceful', percent: 12, color: PatternColors.peaceful),
    ],
    weeklySummary:
        'This week\'s dreams circled the same question three different ways: what gets to stay, and what is already leaving? The water kept rising. The houses kept opening. Something in you is making space.',
  );

  static List<SubscriptionPlan> plans = [
    SubscriptionPlan(id: 'weekly',  title: 'WEEKLY',  price: '\$7.99',  unit: '/wk'),
    SubscriptionPlan(id: 'annual',  title: 'ANNUAL',  price: '\$49.99', unit: '/yr', badge: 'SAVE 87%'),
    SubscriptionPlan(id: 'monthly', title: 'MONTHLY', price: '\$14.99', unit: '/mo'),
  ];

  static List<SignReveal> signReveals = [
    SignReveal(
      sign: ZodiacSign.scorpio,
      label: 'YOUR SUN',
      signName: 'Scorpio',
      description:
          'Your Scorpio Sun burns quiet and steady. You\'re built to see what others would rather not — and you trust the knowing more than you trust the noise.',
      gradient: LumenGradients.sunCard,
    ),
    SignReveal(
      sign: ZodiacSign.cancer,
      label: 'YOUR MOON',
      signName: 'Cancer',
      description:
          'Your Cancer Moon feels everything, holds everything, and remembers everything. It\'s tender and wise at once — the part of you that always knew.',
      gradient: LumenGradients.moonCard,
    ),
    SignReveal(
      sign: ZodiacSign.leo,
      label: 'YOUR RISING',
      signName: 'Leo',
      description:
          'Your Leo Rising is the warm lantern you hold up to the world — even when no one\'s looking. It\'s how people feel you before they know you.',
      gradient: LumenGradients.risingCard,
    ),
  ];
}
