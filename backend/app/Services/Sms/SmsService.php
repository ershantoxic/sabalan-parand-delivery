<?php
namespace App\Services\Sms; interface SmsService { public function sendDeliveryCode(string $mobile,string $orderNumber,string $code):void; }
