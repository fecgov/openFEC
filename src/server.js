const React = require("react");
const ReactDOM = require("react-dom");
const App = require("./App").default;

if (module.hot) {
  ReactDOM.render(<App />, document.getElementById("app"));

  module.hot.accept("./App.js", () => {
    ReactDOM.render(<App />, document.getElementById("app"));
  });
}
