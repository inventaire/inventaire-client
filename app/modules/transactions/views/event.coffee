# the Event view can have both Message or Action models
# the interest mixing those is to allow those views to be displayed
# on chronological order within the transaction timeline
module.exports = Marionette.ItemView.extend
  behaviors:
    PreventDefault: {}

  initialize: ->
    @isMessage = @model.get('message')?
    @setClassNames()

  getTemplate: ->
    if @isMessage then require './templates/message'
    else require './templates/action'

  setClassNames: ->
    if @isMessage then @$el.addClass 'message'
    else @$el.addClass 'action'

  serializeData: ->
    # both Message and Action model implement a serializeData method
    attrs = @model.serializeData()
    attrs.sameUser = @sameUser()
    return attrs

  modelEvents:
    'grab': 'render'

  events:
    'click .username': 'showOtherUser'

  # hide avatar on successsive messages from the same user
  sameUser: ->
    return  unless @isMessage
    index = @model.collection.indexOf(@model)
    return  unless index > 0
    prev = @model.collection.models[index - 1]
    return  unless prev?.get('message')?

    if prev.get('user') is @model.get('user')
      return true

  showOtherUser: (e)->
    unless _.isOpenedOutside(e)
      app.execute 'show:inventory:user', @model.transaction?.otherUser()
