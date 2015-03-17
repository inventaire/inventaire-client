module.exports = class Error extends Backbone.Marionette.LayoutView
  id: 'error'
  className: 'text-center'
  template: require './templates/error'
  serializeData: -> return @options

  events:
    'click .button': 'buttonAction'

  buttonAction: ->
    {buttonAction} = @options.redirection
    if _.isFunction(buttonAction) then buttonAction()