behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Backbone.Marionette.ItemView.extend
  template: require './templates/request_item_modal'
  className: 'requestItemModal'
  behaviors:
    PreventDefault: {}
    Loading: {}
    SuccessCheck: {}

  initialize: -> _.extend @, behaviorsPlugin

  events:
    'click a#sendItemRequest': 'sendRequest'

  ui:
    message: '#message'

  behaviors:
    ElasticTextarea: {}

  onShow: ->
    app.execute 'modal:open'

  serializeData: ->
    item: _.log @model.serializeData(), 'item'
    user: _.log @userData(), 'user'

  userData: ->
    # user should already have been fetched
    user = app.users.findWhere {username: @model.username}
    return user.serializeData()

  sendRequest: ->
    @startLoading('#sendItemRequest')
    @postRequest()
    .then @Check('item request res', -> app.execute('modal:close'))
    .catch @Fail('item request err')

  postRequest: ->
    _.preq.post app.API.requests,
      message: _.log @ui.message.val(), 'message'
      item: _.log @model.id, 'log'
      owner: @model.get('owner')
