module.exports = Backbone.Model.extend
  initialize: ->
    @action = @get('action')

  serializeData: ->
    _.extend @toJSON(),
      icon: @icon()
      context: @context()

  icon: ->
    switch @action
      when 'requested' then 'envelope'
      else _.warn @, 'unknown action', true

  context: ->
    if @transaction?.owner?
      if @transaction.mainUserIsOwner
        if @action in ownerActions then @mainUserAction()
        else @otherUserAction()
      else
        if @action in ownerActions then @otherUserAction()
        else @mainUserAction()

  mainUserAction: -> _.i18n "main_user_#{@action}"
  otherUserAction: ->
    _.i18n "other_user_#{@action}",
      username: @transaction.owner.get('username')

ownerActions = [
  'accept'
  'decline'
  'returned'
]