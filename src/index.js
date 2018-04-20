import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import SwaggerUI from 'swagger-ui';
import 'swagger-ui/dist/swagger-ui.css';

class Container extends React.Component {
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

Container.defaultProps = {
  url: 'http://localhost:5000/swagger/',
};

Container.propTypes = {
  url: PropTypes.string,
};

if (module.hot) {
  ReactDOM.render(<Container />, document.getElementById('app'));

  module.hot.accept();
}

const SwaggerLayout = (url, domNode) =>
  ReactDOM.render(<Container url={url} />, domNode);

module.exports = SwaggerLayout;
