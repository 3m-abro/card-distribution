import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom'; // Provides matchers like "toBeInTheDocument"
import * as matchers from '@testing-library/jest-dom/matchers';
import {expect} from 'my-test-runner/expect';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import CardDistribution from './CardDistribution';

expect.extend(matchers);

// Mock Axios instance
const mock = new MockAdapter(axios);

describe('CardDistribution Component', () => {
  afterEach(() => {
    mock.reset();
  });

  test('renders input and button', () => {
    render(<CardDistribution />);

    // Check that input and button are rendered correctly
    const inputElement = screen.getByPlaceholderText(/Enter number of people/i);
    const buttonElement = screen.getByText(/Distribute Cards/i);

    expect(inputElement).toBeInTheDocument();
    expect(buttonElement).toBeInTheDocument();
  });

  test('displays distributed cards when API responds successfully', async () => {
    // Mock API response
    const mockResponse = {
      distributedCards: [
        ['S-A', 'H-X', 'D-3', 'C-J'],
        ['S-4', 'H-7', 'D-Q', 'C-9'],
      ],
    };
    mock.onPost('/api/distribute-cards').reply(200, mockResponse);

    render(<CardDistribution />);

    const inputElement = screen.getByPlaceholderText(/Enter number of people/i);
    const buttonElement = screen.getByText(/Distribute Cards/i);

    // Simulate user input and form submission
    fireEvent.change(inputElement, { target: { value: '2' } });
    fireEvent.click(buttonElement);

    // Wait for the result to appear after the API call
    await waitFor(() => {
      const cardElements = screen.getAllByRole('listitem');
      expect(cardElements.length).toBe(8); // 2 people with 4 cards each
      expect(screen.getByText(/Person 1: S-A, H-X, D-3, C-J/i)).toBeInTheDocument();
      expect(screen.getByText(/Person 2: S-4, H-7, D-Q, C-9/i)).toBeInTheDocument();
    });
  });

  test('displays error message when API call fails', async () => {
    // Mock API failure
    mock.onPost('/api/distribute-cards').reply(500);

    render(<CardDistribution />);

    const inputElement = screen.getByPlaceholderText(/Enter number of people/i);
    const buttonElement = screen.getByText(/Distribute Cards/i);

    // Simulate user input and form submission
    fireEvent.change(inputElement, { target: { value: '2' } });
    fireEvent.click(buttonElement);

    // Wait for the error message to appear
    await waitFor(() => {
      const errorElement = screen.getByText(/An error occurred while distributing the cards/i);
      expect(errorElement).toBeInTheDocument();
    });
  });
});
