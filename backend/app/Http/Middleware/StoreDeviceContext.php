<?php
namespace App\Http\Middleware; use Closure; use Illuminate\Http\Request;
class StoreDeviceContext { public function handle(Request $request, Closure $next) { $request->attributes->set('device_info', json_encode(['id'=>$request->header('X-Device-Identifier'),'name'=>$request->header('X-Device-Name'),'android'=>$request->header('X-Android-Version'),'app'=>$request->header('X-App-Version')])); return $next($request); } }
