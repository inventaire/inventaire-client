# TRANSACTION STATES (actor)
# - requested (requester)
# - accepted / declined (owner)
# - performed (requester)
# - returned (owner) (for lending only)
# - cancelled (owner/requester)
{ getNextActionsData, isArchived } = require '../lib/next_actions'
cancellableStates = require '../lib/cancellable_states'
applySideEffects = require '../lib/apply_side_effects'

Action = require '../models/action'
Message = require '../models/message'
Timeline = require '../collections/timeline'
formatSnapshotData = require '../lib/format_snapshot_data'
{ data:transactionsData } = require 'modules/inventory/lib/transactions_data'

module.exports = Backbone.NestedModel.extend
  url: -> app.API.transactions
  initialize: ->
    @set 'pathname', "/transactions/#{@id}"

    @setMainUserIsOwner()
    @setArchivedStatus()
    # re-set mainUserIsOwner once app.user.id is accessible
    @listenToOnce app.user, 'change', @setMainUserIsOwner.bind(@)

    @set 'icon', @getIcon()

  beforeShow:->
    # All the actions to run once before showing any view displaying
    # deep transactions data, but that can be spared otherwise
    if @_beforeShowCalledOnce then return
    @_beforeShowCalledOnce = true

    @grabLinkedModels()
    @buildTimeline()
    @fetchMessages()
    # provide views with a flag on actions data state
    @set 'actionsReady', false

    @once 'grab:owner', @setNextActions.bind(@)
    @once 'grab:requester', @setNextActions.bind(@)

    @on 'change:state', @setNextActions.bind(@)
    @on 'change:state', @setArchivedStatus.bind(@)
    @on 'change:read', @deduceReadStatus.bind(@)

    # snapshot data are to be used in views only when the snapshot
    # is more meaningful than the current version
    # ex: the item transaction mode at the time of the transaction request
    formatSnapshotData.call @

  setMainUserIsOwner: ->
    @mainUserIsOwner = @get('owner') is app.user.id
    @role = if @mainUserIsOwner then 'owner' else 'requester'
    @deduceReadStatus()

  deduceReadStatus: ->
    @mainUserRead = @get('read')[@role]

    prev = @unreadUpdate
    @unreadUpdate = if @mainUserRead then 0 else 1
    if @unreadUpdate isnt prev then app.vent.trigger 'transactions:unread:change'

  grabLinkedModels: ->
    @reqGrab 'get:user:model', @get('requester'), 'requester'

    # wait for the owner to be ready to fetch the item
    # to avoid errors at item initialization
    # during sync functions depending on the owner data
    @reqGrab 'get:user:model', @get('owner'), 'owner'
    .then => @reqGrab 'get:item:model', @get('item'), 'item'

  markAsRead: ->
    unless @mainUserRead
      @set "read.#{@role}", true
      _.preq.put app.API.transactions,
        id: @id
        action: 'mark-as-read'
      .catch _.Error('markAsRead')

  buildTimeline: ->
    if @timeline? then return
    @timeline = new Timeline
    for action in @get('actions')
      @addActionToTimeline action

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
    for message in messages
      @timeline.add new Message(message)

  setNextActions: ->
    # /!\ if the other user stops being accessible (ex: deleted user)
    # next actions will never be ready
    if @owner? and @requester?
      @set
        nextActions: getNextActionsData @
        actionsReady: true

  serializeData: ->
    attrs = @toJSON()
    attrs[attrs.state] = true
    _.extend attrs,
      item: @itemData()
      entity: @get 'snapshot.entity'
      owner: @ownerData()
      requester: @requesterData()
      messages: @messages
      mainUserIsOwner: @mainUserIsOwner
      context: @context()
      mainUserRead: @mainUserRead
      cancellable: @isCancellable()

    [ attrs.user, attrs.other ] = @aliasUsers(attrs)

    # Legacy: the title and image were previously snapshot on snapshot.item
    attrs.entity or= {}
    attrs.entity.title or= attrs.item.title
    attrs.entity.image or= attrs.item.pictures?[0]

    return attrs

  itemData: -> @item?.serializeData() or @get('snapshot.item')
  ownerData: -> @owner?.serializeData() or @get('snapshot.owner')
  requesterData: -> @requester?.serializeData() or @get('snapshot.requester')

  aliasUsers: (attrs)->
    if @mainUserIsOwner then [attrs.owner, attrs.requester]
    else [attrs.requester, attrs.owner]

  otherUser: -> if @mainUserIsOwner then @requester else @owner
  otherUserSnapshot: ->
    other = if @mainUserIsOwner then 'requester' else 'owner'
    return @get("snapshot.#{other}")

  getIcon: ->
    transaction = @get 'transaction'
    return transactionsData[transaction].icon

  context: ->
    if @owner?
      transaction = @get 'transaction'
      if @mainUserIsOwner then _.i18n "main_user_#{transaction}"
      else
        _.i18n "other_user_#{transaction}",
          username: @owner?.get('username')

  accepted: -> @updateState 'accepted'
  declined: -> @updateState 'declined'
  confirmed: -> @updateState 'confirmed'
  returned: -> @updateState 'returned'
  cancelled: -> @updateState 'cancelled'

  updateState: (state)->
    @backup()
    # redondant info:
    # might need to be refactored to deduce state from last action
    @set {state: state}
    action = { action: state, timestamp: Date.now() }
    # keep track of the actor when it can be both
    if state in actorCanBeBoth then action.actor = @role
    @push 'actions', action
    actionModel = @addActionToTimeline action
    userStatus = @otherUser().get 'status'

    _.preq.put app.API.transactions,
      id: @id
      state: state
      action: 'update-state'
    # apply side effects only once the server confirmed
    # to avoid having to handle reverting the item if it fails
    .then _.Full(applySideEffects, null, @, state)
    .catch @_updateFail.bind(@, actionModel)

  _updateFail: (actionModel, err)->
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

  isArchived: -> isArchived @
  isCancellable: ->
    [ state, transaction ] = @gets 'state', 'transaction'
    return state in cancellableStates[transaction][@role]

actorCanBeBoth = ['cancelled']