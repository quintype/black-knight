import $ from "jquery";

function togglePublisherMenu(event) {
  $(event.target).parents(".leftbar-publisher").toggleClass("publisher-open");
}

function bindPublishersMenu() {
  $(".leftbar-publishers").find("a.leftbar-publisher-name").click(togglePublisherMenu);
}

module.exports = bindPublishersMenu;
