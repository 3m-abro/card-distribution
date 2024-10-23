<?php

namespace App\Http\Controllers;

use App\Http\Resources\CardResource;
use App\Models\Card;
use Illuminate\Http\Request;
use Exception;

class CardController extends Controller
{
    private $deck;

    public function distribute(Request $request)
    {
        // Step 1: Input validation
        $validated = $request->validate([
            'numberOfPeople' => 'required|integer|min:1',
        ]);

        try {
            $numberOfPeople = $validated['numberOfPeople'];

            // Step 2: Check for irregular input values (custom business logic)
            if ($numberOfPeople > 53) {
                // This is not an irregular case (allowed as per instructions)
                // The cards will be distributed to 53+ people.
                // No irregularity here, so process normally.
            } else if ($numberOfPeople <= 0) {
                // Irregularity found for invalid people count (should already be handled by validation)
                throw new Exception("Irregularity occurred: Invalid number of people");
            }

            // Step 3: Generate deck of cards
            $this->deck = $this->generateDeck();

            // Simulate an irregularity (e.g., incomplete deck)
            if (count($this->deck) != 52) {
                throw new Exception("Irregularity occurred: Deck is incomplete");
            }

            shuffle($this->deck); // Randomize the deck

            // Step 4: Distribute cards among the people
            $distributedCards = [];
            for ($i = 0; $i < $numberOfPeople; $i++) {
                $distributedCards[$i] = [];
            }

            foreach ($this->deck as $index => $card) {
                $personIndex = $index % $numberOfPeople;
                $distributedCards[$personIndex][] = $card;
            }

            // Step 5: Return successful response
            return response()->json([
                'distributedCards' => $distributedCards,
            ], 200);

        } catch (Exception $e) {
            // Handle irregularity and terminate process
            return response()->json([
                'error' => 'Irregularity occurred',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    private function generateDeck()
    {
        // Retrieve deck of 52 cards from the database
        $cards = Card::all();

        // Convert the collection of Card objects to an array of suit-rank strings
        $deck = $cards->map(function ($card) {
            return $card->suit . '-' . $card->rank;
        })->toArray();

        return $deck;
    }
}
