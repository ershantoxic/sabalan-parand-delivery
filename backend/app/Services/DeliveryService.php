<?php

namespace App\Services;

use App\Enums\OrderStatus;
use App\Models\DeliveryCodeAttempt;
use App\Models\DeliveryLog;
use App\Models\Order;
use App\Services\Sms\SmsService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class DeliveryService
{
    public function __construct(private readonly SmsService $sms) {}

    /** Creates a replacement code; only its bcrypt hash remains in the database. */
    public function issueCode(Order $order): void
    {
        DB::transaction(function () use ($order): void {
            $code = (string) random_int(100000, 999999);
            $order->update([
                'delivery_code_hash' => Hash::make($code),
                'delivery_code_created_at' => now(),
                'delivery_code_expires_at' => now()->addHours(config('delivery.code_expiry_hours')),
                'delivery_code_attempts' => 0,
                'delivery_code_locked_at' => null,
                'delivery_code_verified_at' => null,
            ]);
            $this->sms->sendDeliveryCode($order->customer->mobile, $order->order_number, $code);
            $this->log($order, null, 'delivery_code_issued');
        });
    }

    /** @return array{verified: bool, remaining: int} */
    public function verify(Order $order, Request $request): array
    {
        $this->ensureDeliverable($order, $request);
        abort_if($order->delivery_code_verified_at, 409, 'Delivery code was already verified.');
        abort_if($order->delivery_code_locked_at, 423, 'Delivery code is locked. Contact the office.');
        abort_if(! $order->delivery_code_hash || ! $order->delivery_code_expires_at || $order->delivery_code_expires_at->isPast(), 422, 'Delivery code has expired.');

        $success = Hash::check((string) $request->input('code'), $order->delivery_code_hash);
        DeliveryCodeAttempt::create([
            'order_id' => $order->id,
            'visitor_id' => $request->user()->id,
            'success' => $success,
            'ip_address' => $request->ip(),
            'device_info' => $request->attributes->get('device_info'),
        ]);

        $max = config('delivery.max_code_attempts');
        if (! $success) {
            $attempts = $order->increment('delivery_code_attempts');
            if ($attempts >= $max) {
                $order->update(['delivery_code_locked_at' => now()]);
            }
            $this->log($order, $request->user()->id, 'delivery_code_invalid');
            return ['verified' => false, 'remaining' => max(0, $max - $attempts)];
        }

        $order->update([
            'status' => OrderStatus::CodeVerified,
            'delivery_code_verified_at' => now(),
        ]);
        $this->log($order, $request->user()->id, 'delivery_code_verified');
        return ['verified' => true, 'remaining' => $max];
    }

    public function log(Order $order, ?int $visitorId, string $action, ?string $description = null): void
    {
        DeliveryLog::create(['order_id' => $order->id, 'visitor_id' => $visitorId, 'action' => $action, 'description' => $description]);
    }

    public function ensureDeliverable(Order $order, Request $request): void
    {
        abort_unless($request->user()->can('deliver', $order), 403);
        abort_if($order->status === OrderStatus::Delivered, 409, 'Order has already been delivered.');
    }
}
