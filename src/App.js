import React from "react";
import PropTypes from "prop-types";
import { SwaggerUIBundle } from "swagger-ui-dist";
import "swagger-ui-dist/swagger-ui.css";
import Header from "./components/Header";
import Footer from "./components/Footer";
import "./static/css/styles.css";
import "./static/css/custom.css";

class App extends React.Component {
  componentDidMount() {
    SwaggerUIBundle({
      dom_id: "#swagger-container",
      url: this.props.url,
      presets: [SwaggerUIBundle.presets.apis],
      deepLinking: true,
      docExpansion: "none",
    });
  }

  render() {
    return (
      <div>
        <Header />
        <div id="swagger-container" />
        <Footer />
      </div>
    );
  }
}

App.defaultProps = {
  url: "http://localhost:5000/swagger/",
};

App.propTypes = {
  url: PropTypes.string,
};

export default App;
