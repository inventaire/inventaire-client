module.exports = Error = Backbone.Marionette.LayoutView.extend
  id: 'error'
  className: 'text-center'
  template: require './templates/error'
  serializeData: -> return @options

  events:
    'click .button': 'buttonAction'

  buttonAction: ->
    {buttonAction} = @options.redirection
    if _.isFunction(buttonAction) then buttonAction()