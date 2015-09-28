module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: 'text-center hidden'
  template: require './templates/no_user'
  onShow: -> @$el.fadeIn()
  serializeData: ->
    message: @options.message or "can't find anyone with that name"
