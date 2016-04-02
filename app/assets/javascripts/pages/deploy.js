import React from "react";
import ReactDom from "react-dom";
import superagent from "superagent";
import _ from "lodash";

class DeployPage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      publishers: [],
      tags: {}
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

  setTag(env, e) {
    this.setState({tags: _.merge({}, this.state.tags, {[env.id]: e.target.value})});
  }

  deploy(env) {
    var version = this.state.tags[env.id];

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

module.exports = function createComponent(container) {
  ReactDom.render(React.createElement(DeployPage, {}), container);
};
