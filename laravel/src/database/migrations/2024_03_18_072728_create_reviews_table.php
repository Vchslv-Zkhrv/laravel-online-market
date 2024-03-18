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
        Schema::create('reviews', function (Blueprint $table) {

            $table->id();
            $table->timestamps();
            $table->unsignedTinyInteger("rating")->nullable(False)->index("id_review_rating");
            $table->string("comment")->nullable(False)->default("");
            $table->unsignedBigInteger("user_id")->index("id_review_user")->nullable(False);
            $table->unsignedBigInteger("product_id")->index("id_review_product")->nullable(False);

            $table->foreign("product_id", "fkey_review_product")->on("products")->references("id");
            $table->foreign("user_id", "fkey_review_user")->on("users")->references("id");

        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};
