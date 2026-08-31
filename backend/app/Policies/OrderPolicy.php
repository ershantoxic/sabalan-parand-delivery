<?php
namespace App\Policies; use App\Models\Order;use App\Models\User;
class OrderPolicy { public function view(User $user, Order $order):bool {return $user->hasAnyRole(['Super Admin','Admin','Sales Manager']) || ($user->hasAnyRole(['Visitor','Driver']) && $order->visitor_id===$user->id);} public function update(User $user,Order $order):bool{return $this->view($user,$order)&&$order->status->value!=='delivered';} public function deliver(User $user,Order $order):bool{return $user->hasAnyRole(['Visitor','Driver'])&&$order->visitor_id===$user->id;} }
