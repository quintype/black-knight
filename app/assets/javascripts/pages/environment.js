import React from "react";
import ReactDom from "react-dom";
import superagent from "superagent";
import _ from "lodash";

class EnvironmentPage extends React.Component {
  constructor(props) {
    super(props);
    this.loadMore = this.loadMore.bind(this)
    this.state = {
      deployEnv: null,
      tag: null,
      pageToRetrieve: 2
    };
    this.render = require("./environment.rt");
  }

  getPublishers() {
    var self = this;
    superagent
      .get("/api/deploy_environments/" + self.props.deployEnvironmentId + ".json")
      .end((err, response) => {
        let deployEnvironment = response.body.deploy_environment
        let latestDeployment = _.first(deployEnvironment.deployments);
        let stateToSet = {}
        stateToSet['deployEnv'] = deployEnvironment
        if (latestDeployment){
          stateToSet['tag'] = latestDeployment.version
        }
        self.setState(stateToSet);
      });
  }

  loadMore() {
    superagent
      .get("/api/deploy_environments/"+this.props.deployEnvironmentId+"/deployments.json?page="+this.state.pageToRetrieve)
      .end((err, response) => {
        let deployEnvironment = this.state.deployEnv
        let moreDeployments = response.body.more_deployments
        deployEnvironment.deployments = deployEnvironment.deployments.concat(moreDeployments)
        let stateToSet = {}
        stateToSet['deployEnv'] = deployEnvironment
        stateToSet['pageToRetrieve'] = this.state.pageToRetrieve + 1
        this.setState(stateToSet)
      })
  }

  componentDidMount() {
    this.getPublishers()
  }

  setTag(e) {
    var tagValue = e.target.value.trim()
    this.setState({tag:  tagValue});
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
