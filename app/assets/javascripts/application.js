// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.

//= require jquery
//= require jquery_ujs

window.blackKnight = {
  environmentPage: require("./pages/environment"),
  migrationsPage: require("./pages/migrations"),
  deploymentPage: require("./pages/deployment"),
  migrationPage: require("./pages/migration"),
  disposePage: require("./pages/dispose"),
  publishersMenu: require("./pages/publisher_menu"),
  logsPage: require("./pages/log"),
  kubeStatusPage: require("./pages/kube_status"),
  searchPub: require("./util/search")
};
