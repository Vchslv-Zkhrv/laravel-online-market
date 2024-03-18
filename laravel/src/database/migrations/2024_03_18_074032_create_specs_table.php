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
        Schema::create('specs', function (Blueprint $table) {

            $table->id();
            $table->timestamps();
            $table->string("key")->nullable(False)->index("id_spec_key");
            $table->string("value")->nullable(False)->index("id_spec_value");
            $table->unsignedBigInteger("product_id")->nullable(False)->index("id_spec_product");

            $table->foreign("product_id", "fkey_spec_product")->on("products")->references("id");

        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('specs');
    }
};
