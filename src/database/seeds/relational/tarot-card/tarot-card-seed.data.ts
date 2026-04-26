export interface TarotCardSeed {
  sortOrder: number;
  numeral: string;
  name: string;
  keywords: string[];
  whatShows: string;
  appliesToday: string;
  question: string;
}

export const TAROT_DECK_NAME = 'Celestial · 22 Major Arcana';

export const TAROT_SEED: TarotCardSeed[] = [
  {
    sortOrder: 0,
    numeral: '0',
    name: 'The Fool',
    keywords: ['BEGINNINGS', 'INNOCENCE', 'SPONTANEITY'],
    whatShows:
      'The Fool stands at the edge of a cliff, unbothered. This is the card of pure potential — the moment before the story starts, when anything is still possible.',
    appliesToday:
      'Something new is asking you to begin before you feel ready. The ground will catch you.',
    question: 'What would you start today if you stopped needing a guarantee?',
  },
  {
    sortOrder: 1,
    numeral: 'I',
    name: 'The Magician',
    keywords: ['WILLPOWER', 'SKILL', 'MANIFESTATION'],
    whatShows:
      'The Magician holds all four elements — everything needed is already on the table. This is the card of directed intention turning into real action.',
    appliesToday:
      "You have more tools than you think. Today is a good day to act on what you've been planning.",
    question: 'What have you been waiting for permission to begin?',
  },
  {
    sortOrder: 2,
    numeral: 'II',
    name: 'The High Priestess',
    keywords: ['INTUITION', 'MYSTERY', 'INNER KNOWING'],
    whatShows:
      "The High Priestess sits between two pillars, guarding a threshold. She knows things that haven't been spoken. This is the card of what you sense before you can explain it.",
    appliesToday:
      "The answer you've been looking for isn't outside you. Go quiet. It's already there.",
    question: 'What do you already know, even without the evidence?',
  },
  {
    sortOrder: 3,
    numeral: 'III',
    name: 'The Empress',
    keywords: ['ABUNDANCE', 'CREATION', 'NURTURE'],
    whatShows:
      "The Empress is surrounded by growing things. She doesn't force — she tends. This is the card of creativity that comes from care, not urgency.",
    appliesToday:
      "What you've been cultivating quietly is further along than you think. Give it attention today.",
    question: 'What in your life needs tending rather than fixing?',
  },
  {
    sortOrder: 4,
    numeral: 'IV',
    name: 'The Emperor',
    keywords: ['AUTHORITY', 'STRUCTURE', 'STABILITY'],
    whatShows:
      'The Emperor sits on a stone throne. He has built something that holds. This is the card of creating order from chaos — not to control, but to protect.',
    appliesToday:
      "Where you've felt scattered, choose one thing and make it solid. Structure is a form of care.",
    question: 'What would stability actually look like for you right now?',
  },
  {
    sortOrder: 5,
    numeral: 'V',
    name: 'The Hierophant',
    keywords: ['TRADITION', 'GUIDANCE', 'BELIEF'],
    whatShows:
      'The Hierophant passes down what he knows. This is the card of received wisdom — the value of lineage, of learning from those who came before.',
    appliesToday:
      "There's wisdom near you that you may be underestimating. Consider who or what you've been dismissing.",
    question: 'Where in your life might tradition be worth listening to?',
  },
  {
    sortOrder: 6,
    numeral: 'VI',
    name: 'The Lovers',
    keywords: ['CHOICE', 'ALIGNMENT', 'CONNECTION'],
    whatShows:
      "The Lovers stand at a crossroads. This card isn't only about romance — it's about choosing in alignment with your deepest values, even when the choice is hard.",
    appliesToday:
      "A decision is waiting. It won't make itself. Ask which path you'd choose if you weren't afraid.",
    question: 'What are you choosing, and does it reflect who you want to be?',
  },
  {
    sortOrder: 7,
    numeral: 'VII',
    name: 'The Chariot',
    keywords: ['DETERMINATION', 'CONTROL', 'VICTORY'],
    whatShows:
      "The Chariot is pulled by two opposing forces, mastered by will. This is the card of moving forward not because obstacles are gone — but because you've learned to steer.",
    appliesToday:
      'You have more forward momentum than you feel. The resistance is normal. Keep driving.',
    question: 'What are you steering past right now that deserves acknowledgement?',
  },
  {
    sortOrder: 8,
    numeral: 'VIII',
    name: 'Strength',
    keywords: ['COURAGE', 'COMPASSION', 'INNER POWER'],
    whatShows:
      "Strength shows a figure gently taming a lion. This isn't force — it's the quiet power of meeting something wild with steady hands.",
    appliesToday:
      "Gentleness with yourself is not weakness. Where you've been harsh, try patience instead.",
    question: 'What would you handle differently if you led with compassion instead of control?',
  },
  {
    sortOrder: 9,
    numeral: 'IX',
    name: 'The Hermit',
    keywords: ['SOLITUDE', 'REFLECTION', 'INNER GUIDANCE'],
    whatShows:
      'The Hermit walks alone with a lantern, lighting only the next step. This is the card of necessary withdrawal — going inward to find what noise was drowning out.',
    appliesToday:
      "The answer you're looking for won't come from outside input right now. Make space for silence.",
    question: 'What would you hear if you got quiet enough to listen?',
  },
  {
    sortOrder: 10,
    numeral: 'X',
    name: 'Wheel of Fortune',
    keywords: ['CYCLES', 'CHANGE', 'FATE'],
    whatShows:
      'The Wheel turns without asking permission. This card is about cycles — the reminder that what rises falls, and what falls rises again.',
    appliesToday:
      'Whatever feels stuck is already in motion. You may not control the wheel, but you can decide how you meet the turn.',
    question: 'What cycle in your life is completing right now?',
  },
  {
    sortOrder: 11,
    numeral: 'XI',
    name: 'Justice',
    keywords: ['TRUTH', 'FAIRNESS', 'CAUSE AND EFFECT'],
    whatShows:
      "Justice holds scales and a sword. This is the card of honest reckoning — things falling into place not through luck, but through alignment with what's true.",
    appliesToday:
      "Something you've been uncertain about is becoming clearer. Trust what you see, even if it complicates things.",
    question: 'What truth have you been avoiding that deserves to be faced?',
  },
  {
    sortOrder: 12,
    numeral: 'XII',
    name: 'The Hanged Man',
    keywords: ['SUSPENSION', 'SURRENDER', 'NEW PERSPECTIVE'],
    whatShows:
      'The Hanged Man is suspended upside down — and at peace. This is the card of voluntary pause, the wisdom that comes from stopping rather than pushing.',
    appliesToday:
      "The delay you've been fighting might be exactly where the insight lives. Let yourself be still.",
    question:
      'What might you see if you looked at your situation from a completely different angle?',
  },
  {
    sortOrder: 13,
    numeral: 'XIII',
    name: 'Death',
    keywords: ['ENDINGS', 'TRANSITION', 'TRANSFORMATION'],
    whatShows:
      'Death rides slowly, and nothing is the same after. But destruction here is always a clearing — endings that make space for what was waiting to begin.',
    appliesToday: "Something is completing. Let it. The grief is real, and so is what's coming.",
    question: 'What are you holding onto past its time?',
  },
  {
    sortOrder: 14,
    numeral: 'XIV',
    name: 'Temperance',
    keywords: ['BALANCE', 'PATIENCE', 'MODERATION'],
    whatShows:
      'Temperance pours water between two cups — back and forth, endlessly calibrating. This is the card of long patience, of finding the mix that actually works.',
    appliesToday:
      "The extremes aren't serving you. Today, look for the middle path — not compromise, but integration.",
    question: 'Where are you out of balance, and what would true equilibrium feel like?',
  },
  {
    sortOrder: 15,
    numeral: 'XV',
    name: 'The Devil',
    keywords: ['SHADOW', 'BONDAGE', 'MATERIALISM'],
    whatShows:
      'Two figures stand chained, but the chains are loose. They could leave. The Devil is the card of what holds us through habit, fear, or attachment — not force.',
    appliesToday:
      "Notice what you're giving power to today that doesn't deserve it. The chain isn't locked.",
    question: 'What are you staying in that you could actually leave?',
  },
  {
    sortOrder: 16,
    numeral: 'XVI',
    name: 'The Tower',
    keywords: ['UPHEAVAL', 'REVELATION', 'SUDDEN CHANGE'],
    whatShows:
      "The Tower is struck by lightning and people fall. This is the card of sudden collapse — but only of what was never real. What's true survives.",
    appliesToday:
      'Something may shake loose today. Trust that what remains after the disruption is what was always worth keeping.',
    question: 'What false structure in your life is overdue for collapse?',
  },
  {
    sortOrder: 17,
    numeral: 'XVII',
    name: 'The Star',
    keywords: ['HOPE', 'RENEWAL', 'SERENITY'],
    whatShows:
      "After the storm, a figure kneels by still water under a sky full of stars. This is the card of hope that doesn't need proof — the quiet knowing that things will come right.",
    appliesToday:
      'Rest is not retreat. Receiving is not weakness. Let something restore you today.',
    question:
      'What would it feel like to believe, even without certainty, that things are moving toward good?',
  },
  {
    sortOrder: 18,
    numeral: 'XVIII',
    name: 'The Moon',
    keywords: ['INTUITION', 'DREAMS', 'ILLUSION'],
    whatShows:
      'The Moon is the card of the unseen. It speaks to what you sense before you can explain, what pulls at you before you understand why.',
    appliesToday:
      'Your gut has been trying to tell you something about the week ahead. Today, stop asking for proof. Listen.',
    question: 'What do you already know, even without the evidence?',
  },
  {
    sortOrder: 19,
    numeral: 'XIX',
    name: 'The Sun',
    keywords: ['JOY', 'CLARITY', 'VITALITY'],
    whatShows:
      "The Sun shines without condition. A child rides freely beneath it. This is the card of uncomplicated joy — the kind you don't have to earn.",
    appliesToday: "Something genuinely good is available to you today. Don't overthink it.",
    question: "Where in your life is the sun already shining that you've forgotten to notice?",
  },
  {
    sortOrder: 20,
    numeral: 'XX',
    name: 'Judgement',
    keywords: ['REFLECTION', 'CALLING', 'ABSOLUTION'],
    whatShows:
      "Figures rise in response to a call. Judgement is not punishment — it's the moment of honest reckoning that frees you from what you've been dragging.",
    appliesToday: 'What verdict have you been withholding from yourself? You already know. Say it.',
    question: "What would you do differently if you'd fully forgiven yourself for the past?",
  },
  {
    sortOrder: 21,
    numeral: 'XXI',
    name: 'The World',
    keywords: ['COMPLETION', 'INTEGRATION', 'WHOLENESS'],
    whatShows:
      'A figure dances at the center of a wreath. The World is the card of full arrival — not perfection, but completion. The cycle done. The lesson integrated.',
    appliesToday:
      'Something in you has come full circle. Take a moment to acknowledge it before moving on.',
    question: 'What chapter of your story deserves a proper ending before you begin the next?',
  },
];
