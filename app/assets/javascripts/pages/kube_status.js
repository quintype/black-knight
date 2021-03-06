import React from "react";
import ReactDom from "react-dom";

class KubeStatusPage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      appStatus: this.props.appStatus
    };
    this.render = require("./kube_status.rt");
  }

};

module.exports = function createComponent(container, appStatus) {
  ReactDom.render(React.createElement(KubeStatusPage, {appStatus: appStatus}), container);
};
