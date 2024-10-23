<?php

namespace Database\Seeders;

use App\Models\Card;
use Illuminate\Database\Seeder;

class CardSeeder extends Seeder
{
    private $suits = ['S', 'H', 'D', 'C']; // Spades, Hearts, Diamonds, Clubs
    private $ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', 'X', 'J', 'Q', 'K'];

    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        foreach ($this->suits as $suit) {
            foreach ($this->ranks as $rank) {
                Card::create(['suit' => $suit, 'rank' => $rank]);
            }
        }
    }
}
