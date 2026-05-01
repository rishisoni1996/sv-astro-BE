import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import OpenAI from 'openai';
import { AllConfigType } from '../config/config.type';
import { GuidanceAiResult, InterpretationAiResult, SignPosition } from './ai.types';

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);
  private readonly client: OpenAI | null;
  private readonly model: string;

  constructor(private readonly configService: ConfigService<AllConfigType>) {
    const apiKey = this.configService.get('ai.apiKey', { infer: true });
    const baseURL = this.configService.get('ai.baseUrl', { infer: true });
    this.model = this.configService.get('ai.model', { infer: true }) || 'gemini-2.5-flash';
    this.client = apiKey ? new OpenAI({ apiKey, baseURL }) : null;
  }

  private async json<T>(systemPrompt: string, userPrompt: string): Promise<T | null> {
    if (!this.client) {
      this.logger.warn('AI API key not configured — returning null.');
      return null;
    }
    let raw = '';
    try {
      const completion = await this.client.chat.completions.create({
        model: this.model,
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt },
        ],
        response_format: { type: 'json_object' },
      });
      raw = completion.choices[0]?.message?.content ?? '';
      return JSON.parse(raw) as T;
    } catch (err) {
      const e = err as Error & { status?: number; response?: { data?: unknown } };
      this.logger.error(
        `AI JSON call failed: ${e.message} | status=${e.status ?? 'n/a'} | raw=${raw.slice(0, 500)}`,
        e.stack,
      );
      return null;
    }
  }

  private async text(systemPrompt: string, userPrompt: string): Promise<string | null> {
    if (!this.client) return null;
    try {
      const completion = await this.client.chat.completions.create({
        model: this.model,
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt },
        ],
      });
      return completion.choices[0]?.message?.content ?? null;
    } catch (err) {
      const e = err as Error & { status?: number };
      this.logger.error(`AI text call failed: ${e.message} | status=${e.status ?? 'n/a'}`, e.stack);
      return null;
    }
  }

  async generateInterpretation(
    content: string,
    typeTags: string[],
    emotionTags: string[],
  ): Promise<InterpretationAiResult | null> {
    const system =
      'You are Lumen, a gentle, literary dream-interpreter. Respond ONLY with JSON matching the schema {coreMeaning:string, whatReveals:string, guidance:string, symbols: [{emoji:string, name:string}]}. 2-3 sentences per text field. Symbols: up to 5, simple emoji + 1-word name.';
    const user = `Dream: ${content}\nTypeTags: ${typeTags.join(', ')}\nEmotionTags: ${emotionTags.join(', ')}`;
    const result = await this.json<InterpretationAiResult>(system, user);
    if (!result?.coreMeaning || !Array.isArray(result.symbols)) return null;
    return result;
  }

  async generateGuidance(
    sunSign: string,
    moonSign: string,
    risingSign: string,
    date: Date,
  ): Promise<GuidanceAiResult | null> {
    const system =
      'You are Lumen, an astrologer. Respond ONLY with JSON {greeting:string, headline:string, subtext:string, astroContext:string}. greeting: ~6 words including user-agnostic warmth. headline: 1 sentence framing today. subtext: 1-2 sentences of advice. astroContext: a single astrological note ~15 words.';
    const user = `Sun: ${sunSign}, Moon: ${moonSign}, Rising: ${risingSign}. Date: ${date.toISOString().slice(0, 10)}.`;
    return this.json<GuidanceAiResult>(system, user);
  }

  async generateSignReveal(sign: string, position: SignPosition): Promise<string | null> {
    const system =
      'You are Lumen, writing a 2-sentence warm, insightful description of someone with a given astrological sign in a given position. No headings, just prose. ~40 words total.';
    const user = `Sign: ${sign}. Position: ${position}.`;
    return this.text(system, user);
  }

  async generateWeeklySummary(dreamTitles: string[], symbols: string[]): Promise<string | null> {
    const system =
      'You are Lumen. Summarize the themes from this week of dreams in one short reflective paragraph (~70 words). No headings.';
    const user = `Dream titles: ${dreamTitles.join('; ')}\nRecurring symbols: ${symbols.join(', ')}`;
    return this.text(system, user);
  }

  async extractTitle(content: string): Promise<string | null> {
    const system =
      'Extract a short, evocative 3-6 word title for this dream. Respond with plain text only.';
    const user = content.slice(0, 1000);
    const text = await this.text(system, user);
    return text?.trim().slice(0, 300) ?? null;
  }
}
