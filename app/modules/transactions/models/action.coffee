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
      when 'accepted' then 'check'
      when 'confirmed' then 'sign-in'
      when 'declined' then 'times'
      when 'returned' then 'check'
      else _.warn @, 'unknown action', true

  context: ->
    if @transaction?.owner?
      if @transaction.mainUserIsOwner
        if @action in ownerActions then @mainUserAction()
        else @otherUserAction()
      else
        if @action in ownerActions then @otherUserAction()
        else @mainUserAction()

  mainUserAction: -> @userAction 'main'
  otherUserAction: -> @userAction 'other'
  userAction: (user)->
    _.i18n "#{user}_user_#{@action}", { username: @otherUsername() }

  otherUsername: ->
    # injecting an html anchor instead of just a username string
    if @transaction?.otherUser()?
      username = @transaction.otherUser()?.get 'username'
      href = @transaction.otherUser()?.get 'pathname'
      return "<a href='#{href}' class='username'>#{username}</a>"

ownerActions = [
  'accepted'
  'declined'
  'returned'
]