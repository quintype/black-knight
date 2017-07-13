import React from "react";
import ReactDom from "react-dom";
import superagent from "superagent";
import _ from "lodash";

class DisposePage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      deploying: false,
      message: null
    }
    this.render = require("./dispose.rt");
  }

  scaleEnvironment(size) {
    if(this.state.deploying)
      return;

    this.setState({deploying: true});

    superagent
      .post("/api/deploy_environments/" + this.props.deployEnvironmentId + "/scale.json")
      .send({size: size})
      .end((err, response) => this.setState({message: "Scaling Environment"}));
  }
};

module.exports = function createComponent(container, deployEnvironmentId) {
  ReactDom.render(React.createElement(DisposePage, {deployEnvironmentId: deployEnvironmentId}), container);
};
