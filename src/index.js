const React = require("react");
const ReactDOM = require("react-dom");
const App = require("./App").default;

const SwaggerLayout = (url, domNode) =>
  ReactDOM.render(<App url={url} />, domNode);

module.exports = SwaggerLayout;
