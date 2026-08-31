<?php
namespace App\Models; use Illuminate\Database\Eloquent\Model;
class DeliveryCodeAttempt extends Model { public $timestamps=false; protected $fillable=['order_id','visitor_id','success','ip_address','device_info','created_at']; protected $casts=['success'=>'boolean']; }
