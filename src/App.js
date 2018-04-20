import React from 'react';
import PropTypes from 'prop-types';
import SwaggerUI from 'swagger-ui';
import 'swagger-ui/dist/swagger-ui.css';

class App extends React.Component {
  componentDidMount() {
    SwaggerUI({
      dom_id: '#swagger-container',
      url: this.props.url,
      presets: [SwaggerUI.presets.apis],
      deepLinking: true,
      docExpansion: 'none',
    });
  }

  render() {
    return <div id="swagger-container" />;
  }
}

App.defaultProps = {
  url: 'http://localhost:5000/swagger/',
};

App.propTypes = {
  url: PropTypes.string,
};

export default App;
