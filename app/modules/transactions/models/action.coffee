module.exports = Backbone.Model.extend
  initialize: ->
    @action = @get('action')

  serializeData: ->
    _.extend @toJSON(),
      icon: @icon()
      context: @context(true)

  icon: ->
    switch @action
      when 'requested' then 'envelope'
      when 'accepted' then 'check'
      when 'confirmed' then 'sign-in'
      when 'declined', 'cancelled' then 'times'
      when 'returned' then 'check'
      else _.warn @, 'unknown action', true

  context: (withLink)-> @userAction @findUser(), withLink
  findUser: ->
    if @transaction?.owner?
      if @transaction.mainUserIsOwner
        if @action in ownerActions then 'main' else 'other'
      else
        if @action in ownerActions then 'other' else 'main'

  userAction: (user, withLink)->
    if user?
      _.i18n "#{user}_user_#{@action}", { username: @otherUsername(withLink) }

  otherUsername: (withLink)->
    # injecting an html anchor instead of just a username string
    if @transaction?.otherUser()?
      username = @transaction.otherUser()?.get 'username'
      if withLink
        href = @transaction.otherUser()?.get 'pathname'
        return "<a href='#{href}' class='username'>#{username}</a>"
      else username

ownerActions = [
  'accepted'
  'declined'
  'returned'
]