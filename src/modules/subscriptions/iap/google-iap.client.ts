import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { google, androidpublisher_v3 } from 'googleapis';
import { AllConfigType } from '../../../config/config.type';

export interface GoogleVerifyResult {
  ok: boolean;
  expiresAt: Date | null;
}

@Injectable()
export class GoogleIapClient {
  private readonly logger = new Logger(GoogleIapClient.name);

  constructor(private readonly configService: ConfigService<AllConfigType>) {}

  async verify(planId: string, purchaseToken: string): Promise<GoogleVerifyResult> {
    const serviceAccountJson = this.configService.get('iap.googlePlayServiceAccountJson', {
      infer: true,
    });
    const packageName = this.configService.get('iap.googlePlayPackageName', { infer: true });
    if (!serviceAccountJson || !packageName) {
      this.logger.warn('Google Play IAP is not configured');
      return { ok: false, expiresAt: null };
    }

    try {
      const credentials = JSON.parse(serviceAccountJson);
      const auth = new google.auth.GoogleAuth({
        credentials,
        scopes: ['https://www.googleapis.com/auth/androidpublisher'],
      });
      const client = google.androidpublisher({ version: 'v3', auth });

      const resp = await client.purchases.subscriptions.get({
        packageName,
        subscriptionId: planId,
        token: purchaseToken,
      });
      const purchase: androidpublisher_v3.Schema$SubscriptionPurchase = resp.data ?? {};
      const expiryMs = purchase.expiryTimeMillis ? Number(purchase.expiryTimeMillis) : null;
      return {
        ok: true,
        expiresAt: expiryMs ? new Date(expiryMs) : null,
      };
    } catch (err) {
      this.logger.error('Google Play IAP verification failed', err as Error);
      return { ok: false, expiresAt: null };
    }
  }
}
