import React from "react";
import ReactDOM from "react-dom";
import App from "./App";

if (module.hot) {
  ReactDOM.render(<App />, document.getElementById("app"));

  module.hot.accept("./App.js", () => {
    ReactDOM.render(<App />, document.getElementById("app"));
  });
}
