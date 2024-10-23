// src/services/api.js
import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:9000/api', // Laravel backend API base URL
});

export const distributeCards = (numberOfPeople) => {
  return api.post('/distribute-cards', { numberOfPeople });
};
