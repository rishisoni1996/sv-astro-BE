export const DREAM_TYPE_TAGS = ['Nightmare', 'Recurring', 'Lucid', 'Vivid', 'Fragment'] as const;
export type DreamTypeTag = (typeof DREAM_TYPE_TAGS)[number];

export const DREAM_EMOTION_TAGS = ['Peaceful', 'Anxious', 'Confused', 'Inspired', 'Heavy'] as const;
export type DreamEmotionTag = (typeof DREAM_EMOTION_TAGS)[number];
