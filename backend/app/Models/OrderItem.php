<?php
namespace App\Models; use Illuminate\Database\Eloquent\Model;
class OrderItem extends Model { protected $fillable=['order_id','product_id','quantity','weight','unit_price','total_price']; protected $casts=['weight'=>'decimal:3']; public function product(){return $this->belongsTo(Product::class);} }
