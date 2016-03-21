behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.ItemView.extend
  template: require './templates/request_item_modal'
  className: 'requestItemModal'
  behaviors:
    PreventDefault: {}
    Loading: {}
    SuccessCheck: {}
    ElasticTextarea: {}
    General: {}

  initialize: -> _.extend @, behaviorsPlugin

  events:
    'click a#sendItemRequest': 'sendRequest'

  ui:
    message: '#message'

  onShow: ->
    app.execute 'modal:open'

  serializeData: ->
    item: @model.serializeData()
    user: @userData()
    suggestedText: @suggestedText()

  userData: ->
    # user should already have been fetched
    user = app.users.findWhere {username: @model.username}
    return user.serializeData()

  suggestedText: ->
    transaction = @model.get 'transaction'
    return "item_request_text_suggestion_#{transaction}"

  sendRequest: ->
    @startLoading '#sendItemRequest'
    @postRequest()
    .then addTransaction
    .then showRequest
    .catch @Fail('item request err')

  postRequest: ->
    tracker = app.execute.bind app, 'track:transaction', 'request', @userData()?.status
    _.preq.post app.API.transactions,
      action: 'request'
      item: @model.id
      message: @ui.message.val()
    .tap tracker

addTransaction = (transaction)->
  app.request 'transactions:add', transaction

showRequest = (transaction)->
  app.execute 'modal:close'
  app.execute 'show:transaction', transaction.id
