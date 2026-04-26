import { Injectable, Logger } from '@nestjs/common';
import { Body, Ecliptic, GeoVector, SiderealTime } from 'astronomy-engine';
import {
  ComputeSignsInput,
  ComputeSignsResult,
  GeocodeResult,
  ZodiacSign,
} from './astrology.types';

const ZODIAC_SIGNS: ZodiacSign[] = [
  'Aries',
  'Taurus',
  'Gemini',
  'Cancer',
  'Leo',
  'Virgo',
  'Libra',
  'Scorpio',
  'Sagittarius',
  'Capricorn',
  'Aquarius',
  'Pisces',
];

const MEAN_OBLIQUITY_DEG = 23.4393;

const STATIC_GEOCODE: GeocodeResult = {
  latitude: 23.0225,
  longitude: 72.5714,
  timezone: 'Asia/Kolkata',
};

@Injectable()
export class AstrologyService {
  private readonly logger = new Logger(AstrologyService.name);

  async geocode(location: string): Promise<GeocodeResult | null> {
    if (!location?.trim()) return null;
    // TODO: replace with Google Maps Geocoding (forward-geocode + tz lookup).
    // For now, every location resolves to Ahmedabad so downstream compute is exercised.
    this.logger.debug(`geocode() stub returning Ahmedabad for "${location}"`);
    return STATIC_GEOCODE;
  }

  async computeSigns(input: ComputeSignsInput): Promise<ComputeSignsResult> {
    const sunSign = this.computeSunSign(input);
    const moonSign = this.computeMoonSign(input);
    const risingSign = this.computeRisingSign(input);
    return { sunSign, moonSign, risingSign };
  }

  private computeSunSign(input: ComputeSignsInput): ZodiacSign | null {
    const date = this.resolveUtcDate(input);
    if (!date) return null;
    return this.eclipticSignOf(Body.Sun, date);
  }

  private computeMoonSign(input: ComputeSignsInput): ZodiacSign | null {
    const date = this.resolveUtcDate(input);
    if (!date) return null;
    return this.eclipticSignOf(Body.Moon, date);
  }

  private computeRisingSign(input: ComputeSignsInput): ZodiacSign | null {
    if (
      !input.birthTime ||
      !input.timezone ||
      input.latitude == null ||
      input.longitude == null
    ) {
      return null;
    }
    const date = this.resolveUtcDate(input);
    if (!date) return null;
    try {
      const gastHours = SiderealTime(date);
      const lstDeg = normalizeDeg(gastHours * 15 + input.longitude);
      const lstRad = degToRad(lstDeg);
      const obliquityRad = degToRad(MEAN_OBLIQUITY_DEG);
      const latRad = degToRad(input.latitude);

      // Standard ascendant formula (Meeus Ch. 15, atan2 form).
      const ascRad = Math.atan2(
        Math.cos(lstRad),
        -(Math.sin(obliquityRad) * Math.tan(latRad) + Math.cos(obliquityRad) * Math.sin(lstRad)),
      );
      const ascDeg = normalizeDeg(radToDeg(ascRad));
      return signFromEclipticLongitude(ascDeg);
    } catch (err) {
      this.logger.warn(`rising sign compute failed: ${(err as Error).message}`);
      return null;
    }
  }

  private eclipticSignOf(body: Body, date: Date): ZodiacSign | null {
    try {
      const vec = GeoVector(body, date, true);
      const ecl = Ecliptic(vec);
      return signFromEclipticLongitude(ecl.elon);
    } catch (err) {
      this.logger.warn(`${body} ecliptic compute failed: ${(err as Error).message}`);
      return null;
    }
  }

  private resolveUtcDate(input: ComputeSignsInput): Date | null {
    if (!input.birthDate) return null;
    if (input.birthTime && input.timezone) {
      const offset = staticTimezoneOffset(input.timezone);
      if (offset !== null) {
        const d = new Date(`${input.birthDate}T${input.birthTime}:00${offset}`);
        return Number.isNaN(d.getTime()) ? null : d;
      }
    }
    // Date-only fallback: noon UTC. Sign-level precision is fine for sun;
    // moon may be off by ~1 sign at cusp; rising will be skipped upstream.
    const d = new Date(`${input.birthDate}T12:00:00Z`);
    return Number.isNaN(d.getTime()) ? null : d;
  }
}

function normalizeDeg(deg: number): number {
  return ((deg % 360) + 360) % 360;
}

function degToRad(deg: number): number {
  return deg * (Math.PI / 180);
}

function radToDeg(rad: number): number {
  return rad * (180 / Math.PI);
}

function signFromEclipticLongitude(longitudeDeg: number): ZodiacSign {
  return ZODIAC_SIGNS[Math.floor(normalizeDeg(longitudeDeg) / 30)];
}

// Minimal IANA → fixed UTC offset table for timezones currently produced by the
// static geocode stub. When real geocoding lands, replace with date-fns-tz.
function staticTimezoneOffset(timezone: string): string | null {
  switch (timezone) {
    case 'Asia/Kolkata':
      return '+05:30';
    default:
      return null;
  }
}
