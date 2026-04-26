export interface InterpretationAiResult {
  coreMeaning: string;
  whatReveals: string;
  guidance: string;
  symbols: { emoji: string; name: string }[];
}

export interface GuidanceAiResult {
  greeting: string;
  headline: string;
  subtext: string;
  astroContext: string;
}

export type SignPosition = 'sun' | 'moon' | 'rising';
