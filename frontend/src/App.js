// src/App.js
import React from 'react';
import './App.css';
import CardDistribution from './components/CardDistribution';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1>Card Distribution</h1>
        <CardDistribution />
      </header>
    </div>
  );
}

export default App;
