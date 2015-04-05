module.exports = Error = Backbone.Marionette.LayoutView.extend
  id: 'error'
  className: 'text-center'
  template: require './templates/error'
  behaviors:
    PreventDefault: {}

  serializeData: -> return @options

  events:
    'click .button': 'buttonAction'

  buttonAction: (e)->
    unless _.isOpenedOutside(e)
      {buttonAction} = @options.redirection
      if _.isFunction(buttonAction) then buttonAction()
