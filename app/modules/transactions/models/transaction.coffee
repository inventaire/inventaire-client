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
lastState = require '../lib/last_state'

module.exports = Filterable.extend
  url: -> app.API.transactions
  initialize: ->
    @set 'pathname', "/transactions/#{@id}"
    @grabLinkedModels()
    @buildTimeline()
    @fetchMessages()
    @setArchivedStatus()

    # re-set mainUserIsOwner once app.user.id is accessible
    @listenToOnce app.user, 'change', @setMainUserIsOwner.bind(@)
    @once 'grab:owner', @setNextActions.bind(@)
    @once 'grab:requester', @setNextActions.bind(@)
    @on 'change:state', @setNextActions.bind(@)
    @on 'change:state', @setArchivedStatus.bind(@)

  grabLinkedModels: ->
    @reqGrab 'get:item:model', @get('item'), 'item'
    @reqGrab 'get:user:model', @get('owner'), 'owner'
    @reqGrab 'get:user:model', @get('requester'), 'requester'

  setMainUserIsOwner: ->
    @mainUserIsOwner = @get('owner') is app.user.id

  buildTimeline: ->
    @timeline = new Timeline
    @get('actions').forEach @addActionToTimeline.bind(@)

  addActionToTimeline: (action)->
    action = new Action action
    action.transaction = @
    return @timeline.add action

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

  accepted: -> @updateState 'accepted'
  declined: -> @updateState 'declined'
  confirmed: -> @updateState 'confirmed'
  returned: -> @updateState 'returned'

  updateState: (state)->
    @backup()
    # redondant info:
    # might need to be refactored to deduce state from last action
    @set {state: state}
    action = { action: state, timestamp: _.now() }
    @push 'actions', action
    actionModel = @addActionToTimeline action

    _.preq.put app.API.transactions,
      id: @id
      state: state
    .catch @updateFail.bind(@, actionModel)

  updateFail: (actionModel, err)->
    @restore()
    @timeline.remove actionModel
    # let the view handle the error
    throw err

  # quick and dirty backup/restore mechanism
  # fails to delete new attributes
  backup: -> @_backup = @toJSON()
  restore: -> @set @_backup

  setArchivedStatus: ->
    previousStatus = @archived
    @archived = @isArchived()
    if @archived isnt previousStatus
      app.vent.trigger 'transactions:folder:change'

  isArchived: -> @get('state') in lastState[@get('transaction')]
