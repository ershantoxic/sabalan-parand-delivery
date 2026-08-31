<?php

namespace App\Services\Sms;

use Illuminate\Support\Facades\Log;

/**
 * Safe fallback until a real SMS provider is configured.
 *
 * This intentionally never logs a delivery code.  The code is sensitive even
 * in development because application logs can be read by many operators.
 */
class LogSmsService implements SmsService
{
    public function sendDeliveryCode(string $mobile, string $orderNumber, string $code): void
    {
        Log::warning('Delivery SMS provider is not configured; code was not sent.', [
            'order_number' => $orderNumber,
            'mobile_suffix' => substr($mobile, -4),
        ]);
    }
}
