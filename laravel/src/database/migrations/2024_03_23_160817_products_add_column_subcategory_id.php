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

      Schema::table('products', function (Blueprint $table) {

        $table->unsignedBigInteger("subcategory_id")->nullable(False)->index("id_product_subcategory");
        $table->foreign("subcategory_id", "fkey_product_subcategory")->on("subcategories")->references("id");

      });

    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {

      Schema::table('products', function (Blueprint $table) {

        $table->dropColumn("subcategory_id");

      });

    }
};
