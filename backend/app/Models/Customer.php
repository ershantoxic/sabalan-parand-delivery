<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory; use Illuminate\Database\Eloquent\Model;
class Customer extends Model { use HasFactory; protected $fillable=['customer_code','name','company_name','mobile','phone','address','province','city','latitude','longitude','description']; public function orders(){return $this->hasMany(Order::class);} }
