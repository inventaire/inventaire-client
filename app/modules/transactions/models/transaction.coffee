# TRANSACTION STATES (actor)
# - requested (requester)
# - accepted / declined (owner)
# - performed (requester)
# - returned (owner) (for lending only)

getNextActionsData = require '../lib/next_actions'
Filterable = require 'modules/general/models/filterable'
Action = require '../models/action'
Message = require '../models/message'
Timeline = require '../collections/timeline'

module.exports = Filterable.extend
  url: -> app.API.transactions
  initialize: ->
    @grabItemModel()
    @grabOwnerModel()
    @grabRequesterModel()
    @buildTimeline()
    @fetchMessages()

    # re-set mainUserIsOwner once app.user.id is accessible
    @listenToOnce app.user, 'change', @setMainUserIsOwner.bind(@)
    @once 'grab:owner', @setNextActions.bind(@)
    @once 'grab:requester', @setNextActions.bind(@)

  grabItemModel: ->
    app.request 'get:item:model', @get('item')
    .then @grab.bind(@, 'item')

  grabOwnerModel: ->
    app.request 'get:user:model', @get('owner')
    .then @grab.bind(@, 'owner')

  setMainUserIsOwner: ->
    @mainUserIsOwner = @get('owner') is app.user.id

  grabRequesterModel: ->
    app.request 'get:user:model', @get('requester')
    .then @grab.bind(@, 'requester')

  buildTimeline: ->
    @timeline = new Timeline
    @get('actions').forEach (action)=>
      action = new Action action
      action.transaction = @
      @timeline.add action

  fetchMessages: ->
    url = _.buildPath app.API.transactions,
      action: 'get-messages'
      transaction: @id

    _.preq.get url
    .then @addMessagesToTimeline.bind(@)

  addMessagesToTimeline: (messages)->
    messages.forEach (message)=>
      message = new Message message
      @timeline.add message

  setNextActions: ->
    if @owner? and @requester?
      @nextActions = getNextActionsData @

  serializeData: ->
    attrs = @toJSON()
    attrs[attrs.state] = true
    _.extend attrs,
      item: @item?.serializeData()
      owner: @owner?.serializeData()
      requester: @requester?.serializeData()
      messages: @messages
      mainUserIsOwner: @mainUserIsOwner
      nextActions: @nextActions
      icon: @icon()
      context: @context()

    [attrs.user, attrs.other] = @aliasUsers(attrs)
    return attrs

  aliasUsers: (attrs)->
    if @mainUserIsOwner then [attrs.owner, attrs.requester]
    else [attrs.requester, attrs.owner]

  otherUser: -> if @mainUserIsOwner then @requester else @owner

  icon: ->
    if @item?
      transaction = @item?.get('transaction')
      Items.transactions[transaction].icon

  context: ->
    if @item? and @owner?
      transaction = @item?.get('transaction')
      if @mainUserIsOwner then _.i18n "main_user_#{transaction}"
      else
        _.i18n "other_user_#{transaction}",
          username: @owner?.get('username')
