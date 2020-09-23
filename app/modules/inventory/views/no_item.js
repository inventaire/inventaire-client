module.exports = Marionette.ItemView.extend
  tagName: 'div'
  className: 'text-center hidden'
  template: require './templates/no_item'
  onShow: -> @$el.fadeIn()
  serializeData: ->
    showIcon: @options.showIcon isnt false
    message: @options.message or 'nothing here'
