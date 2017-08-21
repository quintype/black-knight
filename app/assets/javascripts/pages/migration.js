import React from "react";
import ReactDom from "react-dom";
import superagent from "superagent";
import _ from "lodash";

class MigrationPage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      deployment: {}
    };
    this.render = require("./deployment.rt");
  }

  getMigration() {
    superagent
      .get("/api/migrations/" + this.props.migrationId + ".json")
      .end((err, response) => this.setState({deployment: response.body.migration}));
  }

  componentDidMount() {
    this.getMigration();
  }
};

module.exports = function createComponent(container, migrationId) {
  ReactDom.render(React.createElement(MigrationPage, {migrationId: migrationId}), container);
};
