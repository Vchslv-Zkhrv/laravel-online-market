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
        Schema::create('orders', function (Blueprint $table) {

            $table->id();
            $table->timestamps();
            $table->dateTime("payed")->nullable(True)->index("id_order_payed");
            $table->dateTime("picked")->nullable(True)->index("id_order_picked");
            $table->dateTime("completed")->nullable(True)->index("id_order_completed");
            $table->dateTime("rejected")->nullable(True)->index("id_order_rejected");
            $table->unsignedBigInteger("customer_id")->nullable(False)->index("id_order_customer");
            $table->unsignedBigInteger("picker_id")->nullable(True)->index("id_order_picker");

            $table->foreign("customer_id", "fkey_order_customer")->on("users")->references("id");
            $table->foreign("picker_id", "fkey_order_picker")->on("users")->references("id");

        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
