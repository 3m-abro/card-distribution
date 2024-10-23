<?php

namespace Tests\Feature;

use App\Http\Controllers\CardController;
use Database\Seeders\CardSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use ReflectionClass;
use Tests\TestCase;

class CardDistributionTest extends TestCase
{
    use RefreshDatabase;

    public function test_cards_are_distributed_correctly()
    {
        $this->seed(CardSeeder::class);

        $response = $this->postJson('/api/distribute-cards', ['numberOfPeople' => 4]);

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'distributedCards' => [
                '*' => [], // Check if each person gets an array of cards
            ],
        ]);

        $cards = $response->json('distributedCards');
        $this->assertCount(13, $cards[0]); // Each person should get 13 cards
        $this->assertCount(13, $cards[1]);
        $this->assertCount(13, $cards[2]);
        $this->assertCount(13, $cards[3]);
    }

    public function test_invalid_number_of_people()
    {
        $this->seed(CardSeeder::class);

        $response = $this->postJson('/api/distribute-cards', ['numberOfPeople' => -1]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors('numberOfPeople');
    }

    public function test_zero_people_returns_validation_error()
    {
        $this->seed(CardSeeder::class);

        $response = $this->postJson('/api/distribute-cards', ['numberOfPeople' => 0]);

        $response->assertStatus(422);
        $response->assertJsonValidationErrors('numberOfPeople');
    }

    public function test_irregular_case_invalid_number_of_people()
    {
        $this->seed(CardSeeder::class);

        // Simulate an irregularity (invalid people count)
        $response = $this->postJson('/api/distribute-cards', ['numberOfPeople' => -5]);

        $response->assertStatus(422); // Expecting a 422 status for invalid input
        $response->assertJsonValidationErrors('numberOfPeople');
    }

    public function test_irregular_case_incomplete_deck()
    {
        // Manually modify the deck generation to create an incomplete deck
        $controller = new CardController();
        $reflection = new ReflectionClass($controller);
        $method = $reflection->getMethod('generateDeck');
        $method->setAccessible(true);

        $deck = $method->invoke($controller);
        $deck = array_slice($deck, 0, 51); // Create an incomplete deck with 51 cards

        // Inject the modified deck back into the controller
        $deckProperty = $reflection->getProperty('deck');
        $deckProperty->setAccessible(true);
        $deckProperty->setValue($controller, $deck);

        // Test the distribution with the incomplete deck
        $response = $this->postJson('/api/distribute-cards', ['numberOfPeople' => 4]);

        $response->assertStatus(500); // Expecting a 500 status for irregularity
        $response->assertJson([
            'error' => 'Irregularity occurred',
            'message' => 'Irregularity occurred: Deck is incomplete',
        ]);
    }
}
