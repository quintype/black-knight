import React from "react";
import ReactDom from "react-dom";
import superagent from "superagent";

class DeployPage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      publishers: []
    };
    this.render = require("./deploy.rt");
  }

  getPublishers() {
    superagent
      .get("/api/publishers.json")
      .end((err, response) => this.setState({publishers: response.body.publishers}));
  }

  componentDidMount() {
    this.getPublishers()
  }
};

module.exports = function createComponent(container) {
  ReactDom.render(React.createElement(DeployPage, {}), container);
};
