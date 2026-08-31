<?php
namespace App\Models;
use App\Enums\OrderStatus; use Illuminate\Database\Eloquent\Model; use Illuminate\Database\Eloquent\Relations\BelongsTo;
class Order extends Model {
 protected $fillable=['order_number','customer_id','visitor_id','order_date','delivery_date','total_weight','total_amount','status','delivery_code_hash','delivery_code_created_at','delivery_code_expires_at','delivery_code_attempts','delivery_code_locked_at','delivery_code_verified_at','delivery_started_at','delivered_at','delivered_by','delivery_failed_at','failure_reason','notes'];
 protected $casts=['status'=>OrderStatus::class,'order_date'=>'date','delivery_date'=>'date','delivery_code_created_at'=>'datetime','delivery_code_expires_at'=>'datetime','delivery_code_locked_at'=>'datetime','delivery_code_verified_at'=>'datetime','delivery_started_at'=>'datetime','delivered_at'=>'datetime','delivery_failed_at'=>'datetime','total_weight'=>'decimal:3'];
 public function customer():BelongsTo{return $this->belongsTo(Customer::class);} public function visitor():BelongsTo{return $this->belongsTo(User::class,'visitor_id');} public function items(){return $this->hasMany(OrderItem::class);} public function payments(){return $this->hasMany(Payment::class);} public function logs(){return $this->hasMany(DeliveryLog::class);} }
