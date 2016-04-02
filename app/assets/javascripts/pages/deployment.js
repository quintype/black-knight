import React from "react";
import ReactDom from "react-dom";
import superagent from "superagent";

class DeploymentPage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      deployment: {}
    };
    this.render = require("./deployment.rt");
  }

  getDeployment() {
    superagent
      .get("/api/deployments/" + this.props.deploymentId + ".json")
      .end((err, response) => this.setState({deployment: response.body.deployment}));
  }

  componentDidMount() {
    this.getDeployment()
  }
};

module.exports = function createComponent(container, deploymentId) {
  ReactDom.render(React.createElement(DeploymentPage, {deploymentId: deploymentId}), container);
};
