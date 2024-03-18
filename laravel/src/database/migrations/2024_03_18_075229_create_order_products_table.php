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
        Schema::create('order_products', function (Blueprint $table) {

            $table->id();
            $table->timestamps();
            $table->unsignedInteger("count")->nullable(False)->default(1)->index("id_order_product_count");
            $table->unsignedBigInteger("order_id")->nullable(False)->index("id_order_product_order");
            $table->unsignedBigInteger("product_id")->nullable(False)->index("id_order_product_product");

            $table->foreign("order_id", "fkey_order_product_order")->on("orders")->references("id");
            $table->foreign("product_id", "fkey_order_product_product")->on("products")->references("id");

        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('order_products');
    }
};
