<?php
namespace App\Models; use Illuminate\Database\Eloquent\Model;
class AuditLog extends Model { public $timestamps=false; protected $fillable=['user_id','action','subject_type','subject_id','metadata','ip_address','device_info','created_at']; protected $casts=['metadata'=>'array']; }
