// src/components/CardDistribution.js
import React, { useState } from 'react';
import { distributeCards } from '../services/api';

const CardDistribution = () => {
  const [numberOfPeople, setNumberOfPeople] = useState('');
  const [cards, setCards] = useState([]);
  const [error, setError] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(null);

    try {
      const result = await distributeCards(numberOfPeople);
      setCards(result.data.distributedCards);
    } catch (err) {
      setError('An error occurred while distributing the cards.');
    }
  };

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <input
          type="number"
          value={numberOfPeople}
          onChange={(e) => setNumberOfPeople(e.target.value)}
          placeholder="Enter number of people"
          required
        />
        <button type="submit">Distribute Cards</button>
      </form>

      {error && <p style={{ color: 'red' }}>{error}</p>}

      {cards.length > 0 && (
        <div>
          <h3>Distributed Cards:</h3>
          <ul>
            {cards.map((personCards, index) => (
              <li key={index}>
                Person {index + 1}: {personCards.join(', ')}
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
};

export default CardDistribution;
