import { render, screen } from '@testing-library/react';
import App from './App';

test('renders Card Distribution text', () => {
  render(<App />);
  const linkElement = screen.getByText(/Card Distribution/i);
  expect(linkElement).toBeInTheDocument();
});
