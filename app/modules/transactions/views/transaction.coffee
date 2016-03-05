behaviorsPlugin = require 'modules/general/plugins/behaviors'
messagesPlugin = require 'modules/general/plugins/messages'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'

module.exports = Marionette.CompositeView.extend
  template: require './templates/transaction'
  id: 'transactionView'
  behaviors:
    AlertBox: {}
    ElasticTextarea: {}
    PreventDefault: {}
    BackupForm: {}
    ConfirmationModal: {}

  initialize: ->
    @lazyRender = _.LazyRender @
    @collection = @model.timeline
    @initPlugins()

  initPlugins: ->
    _.extend @, behaviorsPlugin, messagesPlugin

  serializeData: -> @model.serializeData()

  onShow: ->
    @model.markAsRead()
    if _.smallScreen() and not @options.nonExplicitSelection
      _.scrollTop @$el

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
    unless _.isOpenedOutside(e)
      app.execute 'show:item:show:from:model', @model.item

  showOwner: (e)->
    unless _.isOpenedOutside(e)
      app.execute 'show:inventory:user', @model.owner

  cancel: ->
    @$el.trigger 'askConfirmation',
      confirmationText: _.i18n 'transaction_cancel_confirmation'
      action: @model.cancelled.bind(@)
      selector: '.cancel'
