<?php

namespace App\Enums;

enum OrderStatus: string
{
    case Pending = 'pending'; case Assigned = 'assigned'; case OutForDelivery = 'out_for_delivery';
    case CodeVerified = 'delivery_code_verified'; case Delivered = 'delivered';
    case DeliveryFailed = 'delivery_failed'; case Cancelled = 'cancelled';

    public function label(): string { return match($this) {
        self::Pending => 'در انتظار', self::Assigned => 'اختصاص داده شده', self::OutForDelivery => 'در حال تحویل',
        self::CodeVerified => 'کد تأیید شده', self::Delivered => 'تحویل شده', self::DeliveryFailed => 'تحویل ناموفق', self::Cancelled => 'لغو شده',
    }; }
}
