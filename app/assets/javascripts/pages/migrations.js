import React from "react";
import ReactDom from "react-dom";
import superagent from "superagent";
import _ from "lodash";

class Migrations extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      deployEnv: null,
      command: [],
      tag: null,
      pageToRetrieve: 2
    };
    this.render = require("./migrations.rt");
  }

  getPublishers() {
    var self = this;
    superagent
      .get("/api/deploy_environments/" + self.props.deployEnvironmentId + ".json")
      .end((err, response) => {
        let deployEnvironment = response.body.deploy_environment
        let latestMigration = _.first(deployEnvironment.migrations);
        let stateToSet = {}
        stateToSet['deployEnv'] = deployEnvironment
        if (latestMigration){
          stateToSet['tag'] = latestMigration.version;
          stateToSet['command'] = JSON.parse(latestMigration.migration_command);
        }
        self.setState(stateToSet);
      });
  }

  componentDidMount() {
    this.getPublishers()
  }

  setTag(e) {
    var tagValue = e.target.value.trim()
    this.setState({tag:  tagValue});
  }

  commandAsString() {
    this.state.command.join(" ")
  }

  setCommand(e) {
    this.setState({command: e.target.value.trim().split(" ")})
  }

  deploy(env) {
    var version = this.state.tag;

    if(this.state.deploying)
      return;

    if(!version || version == "" || this.state.command.length == 0)
      return;

    this.setState({deploying: true});

    superagent
      .post("/api/migrations.json")
      .send({
        migration: {
          deploy_environment_id: env.id,
          version: version,
          migration_command: this.state.command
        }
      })
      .end((err, response) => window.location = "/environments/" + env.id +"/migration/" + response.body.migration.id);
  }
};

module.exports = function createComponent(container, deployEnvironmentId) {
  ReactDom.render(React.createElement(Migrations, {deployEnvironmentId: deployEnvironmentId}), container);
};
