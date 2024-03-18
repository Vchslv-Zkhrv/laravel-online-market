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
        Schema::create('subcategories', function (Blueprint $table) {

            $table->id();
            $table->timestamps();
            $table->string("name")->nullable(False)->unique("idx_subcategory_name");
            $table->unsignedBigInteger("category_id")->nullable(False)->index("id_subcategory_category");

            $table->foreign("category_id", "fkey_subcategory_category")->on("categories")->references("id");

        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('subcategories');
    }
};
