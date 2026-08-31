<?php
namespace App\Services\Sms; use Illuminate\Support\Facades\Log;
class LogSmsService implements SmsService { public function sendDeliveryCode(string $mobile,string $orderNumber,string $code):void { Log::info('Development delivery SMS',compact('mobile','orderNumber','code')); } }
