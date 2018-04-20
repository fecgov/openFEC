import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';

const SwaggerLayout = (url, domNode) =>
  ReactDOM.render(<App url={url} />, domNode);

module.exports = SwaggerLayout;
