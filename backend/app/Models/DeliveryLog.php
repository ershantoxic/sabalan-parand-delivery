<?php
namespace App\Models; use Illuminate\Database\Eloquent\Model;
class DeliveryLog extends Model { public $timestamps=false; protected $fillable=['order_id','visitor_id','action','description','latitude','longitude','device_info','ip_address','created_at']; }
