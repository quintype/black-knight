var cable = null;

function subscribeToCable(channel, callbacks) {
  cable = cable || ActionCable.createConsumer();
  cable.subscriptions.create(channel, callbacks);
}

module.exports = {
  subscribe: subscribeToCable
};
