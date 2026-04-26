import { createHash } from 'crypto';

export function sha256Mod(input: string, modulo: number): number {
  const digest = createHash('sha256').update(input).digest();
  const slice = digest.readUInt32BE(0);
  return slice % modulo;
}
