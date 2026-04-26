import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AllConfigType } from '../../../config/config.type';

const APPLE_PROD = 'https://buy.itunes.apple.com/verifyReceipt';
const APPLE_SANDBOX = 'https://sandbox.itunes.apple.com/verifyReceipt';

export interface AppleVerifyResult {
  ok: boolean;
  expiresAt: Date | null;
  rawStatus: number;
}

@Injectable()
export class AppleIapClient {
  private readonly logger = new Logger(AppleIapClient.name);

  constructor(private readonly configService: ConfigService<AllConfigType>) {}

  async verify(receiptData: string): Promise<AppleVerifyResult> {
    const secret = this.configService.get('iap.appleSharedSecret', { infer: true });
    if (!secret) {
      this.logger.warn('APPLE_IAP_SHARED_SECRET is not configured');
      return { ok: false, expiresAt: null, rawStatus: -1 };
    }

    const body = JSON.stringify({
      'receipt-data': receiptData,
      password: secret,
      'exclude-old-transactions': true,
    });

    let result = await this.call(APPLE_PROD, body);
    if (result && result.status === 21007) {
      result = await this.call(APPLE_SANDBOX, body);
    }
    if (!result) return { ok: false, expiresAt: null, rawStatus: -1 };

    if (result.status !== 0) {
      return { ok: false, expiresAt: null, rawStatus: result.status };
    }

    const latest = (result.latest_receipt_info ?? [])[0];
    const expiresMs = latest?.expires_date_ms ? Number(latest.expires_date_ms) : null;
    return {
      ok: true,
      expiresAt: expiresMs ? new Date(expiresMs) : null,
      rawStatus: 0,
    };
  }

  private async call(url: string, body: string): Promise<AppleReceiptResponse | null> {
    try {
      const resp = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body,
      });
      return (await resp.json()) as AppleReceiptResponse;
    } catch (err) {
      this.logger.error('Apple receipt verification failed', err as Error);
      return null;
    }
  }
}

interface AppleReceiptResponse {
  status: number;
  latest_receipt_info?: { expires_date_ms?: string }[];
}
