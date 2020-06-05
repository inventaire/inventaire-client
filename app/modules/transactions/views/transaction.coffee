behaviorsPlugin = require 'modules/general/plugins/behaviors'
messagesPlugin = require 'modules/general/plugins/messages'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
screen_ = require 'lib/screen'

module.exports = Marionette.CompositeView.extend
  template: require './templates/transaction'
  id: 'transactionView'
  behaviors:
    AlertBox: {}
    ElasticTextarea: {}
    PreventDefault: {}
    BackupForm: {}

  initialize: ->
    @collection = @model.timeline
    @initPlugins()
    @model.beforeShow()

  initPlugins: ->
    _.extend @, behaviorsPlugin, messagesPlugin

  serializeData: -> @model.serializeData()

  onShow: ->
    @model.markAsRead()
    if screen_.isSmall() and not @options.nonExplicitSelection
      screen_.scrollTop @$el

  modelEvents:
    'grab': 'lazyRender'
    'change': 'lazyRender'

  childViewContainer: '.timeline'
  childView: require './event'

  ui:
    message: 'textarea.message'
    avatars: '.avatar img'

  events:
    'click .sendMessage': 'sendMessage'
    'click .accept': 'accept'
    'click .decline': 'decline'
    'click .confirm': 'confirm'
    'click .returned': 'returned'
    'click .archive': 'archive'
    'click .item': 'showItem'
    'click .owner': 'showOwner'
    'click .cancel': 'cancel'
    # Those anchors being generated within the i18n shortkeys flow
    # that's the best selector we can get
    'click .info a[href^="/items/"]': 'showItem'

  sendMessage: ->
    @postMessage 'transaction:post:message', @model.timeline

  accept: -> @updateState 'accepted'
  decline: -> @updateState 'declined'
  confirm: -> @updateState 'confirmed'
  returned: -> @updateState 'returned'
  archive: -> @updateState 'archive'

  updateState: (state)->
    @model.updateState(state)
    .catch error_.Complete('.actions')
    .catch forms_.catchAlert.bind(null, @)

  showItem: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:item', @model.item

  showOwner: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:inventory:user', @model.owner

  cancel: ->
    app.execute 'ask:confirmation',
      confirmationText: _.i18n 'transaction_cancel_confirmation'
      action: @model.cancelled.bind(@)
      selector: '.cancel'
