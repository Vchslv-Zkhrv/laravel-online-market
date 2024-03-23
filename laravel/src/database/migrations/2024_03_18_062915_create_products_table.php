<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->timestamps();
            $table->string("name")->nullable(False)->index("id_products_name");
            $table->unsignedInteger("price")->nullable(True);
            $table->unsignedBigInteger("sku")->nullable(False)->index("id_products_sku");
            $table->unsignedInteger("balance")->nullable(False)->default(0);
            $table->unsignedBigInteger("image_id")->nullable(True);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
