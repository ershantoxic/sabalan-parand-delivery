<?php

return [
    'code_expiry_hours' => (int) env('DELIVERY_CODE_EXPIRY_HOURS', 24),
    'max_code_attempts' => (int) env('DELIVERY_CODE_MAX_ATTEMPTS', 5),
    'sms_driver' => env('SMS_DRIVER', 'log'),
];
