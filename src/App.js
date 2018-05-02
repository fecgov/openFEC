import React from 'react';
import PropTypes from 'prop-types';
import SwaggerUI from 'swagger-ui';
import 'swagger-ui/dist/swagger-ui.css';
import Header from './components/Header';
import Footer from './components/Footer';
import './static/css/styles.css';
import './static/css/custom.css';

const AugmentingLayout = (props) => {
  const BaseLayout = props.getComponent('BaseLayout', true);

  return (
    <div>
      <Header />
      <BaseLayout />
      <Footer />
    </div>
  );
};

AugmentingLayout.defaultProps = {
  getComponent: () => {},
};

AugmentingLayout.propTypes = {
  getComponent: PropTypes.func,
};

const AugmentingLayoutPlugin = () => ({
  components: {
    AugmentingLayout,
  },
});

class App extends React.Component {
  componentDidMount() {
    SwaggerUI({
      dom_id: '#swagger-container',
      url: this.props.url,
      presets: [SwaggerUI.presets.apis],
      deepLinking: true,
      docExpansion: 'none',
      plugins: [AugmentingLayoutPlugin],
      layout: 'AugmentingLayout',
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
