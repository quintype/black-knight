import React from "react";
import ReactDom from "react-dom";
import superagent from "superagent";
import _ from "lodash";

class LogsPage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      logFile: this.props.logFiles[0],
      lines: 10,
      pod: this.props.podList[0],
      logOutput: "",
    };
    this.render = require("./log.rt");
  }

  handleLineChange(lines) {
    this.setState({
      lines: lines
    })
  }

  handleLogFileChange(file) {
    this.setState({
      logFile: file
    })
  }

  handlePodChange(pod) {
    this.setState({
      pod: pod
    })
  }

  submitLogInfo(e) {
    e.preventDefault();
    superagent
      .get("/api/logs/" + this.props.envId)
      .query({"log_file": this.state.logFile,
              "pod":      this.state.pod,
              "lines":    this.state.lines})
      .end((err, response) => {
        this.setState({logOutput: response.body.log_output})
      });

  }

};

module.exports = function createComponent(container, envId, logFiles, podList) {
  ReactDom.render(React.createElement(LogsPage, {envId: envId, logFiles: logFiles, podList: podList}), container);
};
