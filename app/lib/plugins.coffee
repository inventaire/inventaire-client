# Expects to be passed a view as context, an events object and the associated handlers
# ex: basicPlugin.call @, events, handlers
basicPlugin = (events, handlers)->
  @events or= {}
  _.extend @events, events
  _.extend @, handlers
  return

module.exports = plugins_ =
  # Let the view call the plugin with the view as context
  # ex: module.exports = BasicPlugin events, handlers
  BasicPlugin: (events, handlers)-> _.partial basicPlugin, events, handlers
