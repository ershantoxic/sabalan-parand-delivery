<?php
namespace App\Http\Controllers\Api; use App\Http\Controllers\Controller;
abstract class ApiController extends Controller { protected function ok(mixed $data=null,string $message='عملیات با موفقیت انجام شد.',int $status=200){return response()->json(['success'=>true,'message'=>$message,'data'=>$data],$status);} protected function fail(string $message,array $errors=[],int $status=422){return response()->json(['success'=>false,'message'=>$message,'errors'=>$errors],$status);} }
