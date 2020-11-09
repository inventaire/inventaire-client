// Expects to be passed a view as context, an events object and the associated handlers
// ex: basicPlugin.call @, events, handlers
const basicPlugin = function (events, handlers) {
  if (!this.events) this.events = {}
  _.extend(this.events, events)
  _.extend(this, handlers)
}

// Let the view call the plugin with the view as context
// ex: module.exports = BasicPlugin events, handlers
export const BasicPlugin = (events, handlers) => _.partial(basicPlugin, events, handlers)
