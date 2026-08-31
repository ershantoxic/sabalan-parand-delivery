<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration { public function up():void {
 $n=config('permission.table_names');
 Schema::create($n['permissions'],function(Blueprint $t){$t->id();$t->string('name');$t->string('guard_name');$t->timestamps();$t->unique(['name','guard_name']);});
 Schema::create($n['roles'],function(Blueprint $t){$t->id();$t->string('name');$t->string('guard_name');$t->timestamps();$t->unique(['name','guard_name']);});
 Schema::create($n['model_has_permissions'],function(Blueprint $t)use($n){$t->unsignedBigInteger('permission_id');$t->string('model_type');$t->unsignedBigInteger('model_id');$t->primary(['permission_id','model_id','model_type']);});
 Schema::create($n['model_has_roles'],function(Blueprint $t)use($n){$t->unsignedBigInteger('role_id');$t->string('model_type');$t->unsignedBigInteger('model_id');$t->primary(['role_id','model_id','model_type']);});
 Schema::create($n['role_has_permissions'],function(Blueprint $t)use($n){$t->unsignedBigInteger('permission_id');$t->unsignedBigInteger('role_id');$t->primary(['permission_id','role_id']);});
 } public function down():void {foreach(array_reverse(config('permission.table_names')) as $table)Schema::dropIfExists($table);} };
