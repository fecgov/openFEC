import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';

ReactDOM.render(
  <App url={window.swaggerUrl} />,
  document.getElementById('swagger-ui')
);
