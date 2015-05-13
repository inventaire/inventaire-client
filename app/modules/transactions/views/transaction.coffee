behaviorsPlugin = require 'modules/general/plugins/behaviors'
messagesPlugin = require 'modules/general/plugins/messages'
forms_ = require 'modules/general/lib/forms'

module.exports = Marionette.CompositeView.extend
  template: require './templates/transaction'
  className: 'transaction'
  behaviors:
    AlertBox: {}
    ElasticTextarea: {}

  initialize: ->
    @lazyRender = _.debounce @render.bind(@), 200
    @collection = @model.timeline
    @initPlugins()

  initPlugins: ->
    _.extend @, behaviorsPlugin, messagesPlugin

  serializeData: -> @model.serializeData()

  modelEvents:
    'grab': 'lazyRender'

  childViewContainer: '.timeline'
  childView: require './event'

  ui:
    message: 'textarea.message'
    avatars: '.avatar img'

  events:
    'click .sendMessage': 'sendMessage'

  sendMessage: ->
    @postMessage 'transaction:post:message', @model.timeline
