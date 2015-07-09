module.exports = Marionette.ItemView.extend
  template: require './templates/no_group'
  className: 'noGroup'
  tagName: 'li'
  serializeData: ->
    message: @options.message
