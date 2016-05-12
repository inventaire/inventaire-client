module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: 'text-center hidden'
  template: require './templates/no_user'

  behaviors:
    PreventDefault: {}

  initialize: -> @getLink()

  getLink: ->
    { link } = @options
    if link?
      return @link = links[link]

  onShow: -> @$el.fadeIn()

  serializeData: ->
    message: @options.message or "can't find anyone with that name"
    link: @link

  events:
    'click .linkAction': 'triggerLinkAction'

  triggerLinkAction: (e)->
    unless _.isOpenedOutside e then @link.action()

links =
  inviteFriends:
    text: 'invite friends'
    href: '/network/users/invite'
    action: -> app.execute 'show:network', 'invite'
