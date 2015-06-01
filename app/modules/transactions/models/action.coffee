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
      when 'declined' then 'times'
      when 'returned' then 'check'
      else _.warn @, 'unknown action', true

  context: (withLink)->
    if @transaction?.owner?
      if @transaction.mainUserIsOwner
        if @action in ownerActions then @mainUserAction(withLink)
        else @otherUserAction(withLink)
      else
        if @action in ownerActions then @otherUserAction(withLink)
        else @mainUserAction(withLink)

  mainUserAction: (withLink)-> @userAction 'main', withLink
  otherUserAction: (withLink)-> @userAction 'other', withLink
  userAction: (user, withLink)->
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