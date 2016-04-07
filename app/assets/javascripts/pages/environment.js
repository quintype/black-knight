import React from "react";
import ReactDom from "react-dom";
import superagent from "superagent";

class EnvironmentPage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      deployEnv: null,
      tag: null
    };
    this.render = require("./environment.rt");
  }

  getPublishers() {
    superagent
      .get("/api/deploy_environments/" + this.props.deployEnvironmentId + ".json")
      .end((err, response) => this.setState({deployEnv: response.body.deploy_environment}));
  }

  componentDidMount() {
    this.getPublishers()
  }

  setTag(e) {
    this.setState({tag:  e.target.value});
  }

  deploy(env) {
    var version = this.state.tag;

    if(this.state.deploying)
      return;

    if(!version || version == "")
      return;

    this.setState({deploying: true});

    superagent
      .post("/api/deployments.json")
      .send({
	deployment: {
	  deploy_environment_id: env.id,
	  version: version
	}
      })
      .end((err, response) => window.location = "/deploy/" + response.body.deployment.id);
  }
};

module.exports = function createComponent(container, deployEnvironmentId) {
  ReactDom.render(React.createElement(EnvironmentPage, {deployEnvironmentId: deployEnvironmentId}), container);
};
