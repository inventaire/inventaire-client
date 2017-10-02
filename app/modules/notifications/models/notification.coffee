module.exports = Backbone.NestedModel.extend
  initialize: ->
    @on 'change:status', @update

  beforeShow: ->
    if @_beforeShowAlreadyCalled then return
    @_beforeShowAlreadyCalled = true
    @initSpecific()

  # to override in inherinting models
  initSpecific: ->

  update: ->
    @collection.updateStatus @get('time')

  isUnread: -> @get('status') is 'unread'

  grabAttributeModel: (attribute)->
    app.request 'waitForNetwork'
    .then =>
      id = @get "data.#{attribute}"
      @reqGrab "get:#{attribute}:model", id, attribute

  grabAttributesModels: (attributes...)->
    Promise.all attributes.map(@grabAttributeModel.bind(@))
