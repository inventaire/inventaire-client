module.exports = Marionette.ItemView.extend
  template: require './templates/no_group'
  className: 'noGroup'
  tagName: 'li'
  serializeData: ->
    message: @options.message
  onShow: ->
    @$el.hide().fadeIn()

  events:
    'click #create': -> app.execute 'show:group:create'