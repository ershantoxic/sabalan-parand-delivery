<?php
namespace App\Models; use Illuminate\Database\Eloquent\Model;
class Payment extends Model { protected $fillable=['order_id','visitor_id','method','amount','reference_number','card_last_four','bank_name','cheque_number','cheque_due_date','issuer_name','cheque_image_path','promise_date','description']; protected $casts=['cheque_due_date'=>'date','promise_date'=>'date']; }
