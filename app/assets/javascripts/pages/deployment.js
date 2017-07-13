import React from "react";
import ReactDom from "react-dom";
import superagent from "superagent";
import _ from "lodash";

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
    this.getDeployment();
  }

  confirmRedeploy() {
    var deployNumber = prompt("Please enter the deployment id to redeploy");
    if(deployNumber == this.props.deploymentId)
      superagent
      .post("/api/deployments/" + this.props.deploymentId + "/redeployment.json")
      .end((err, response) => window.location = "/deploy/" + response.body.deployment.id)
  }
};

module.exports = function createComponent(container, deploymentId) {
  ReactDom.render(React.createElement(DeploymentPage, {deploymentId: deploymentId}), container);
};
