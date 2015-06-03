module.exports = Marionette.LayoutView.extend
  id: 'error'
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

  onShow: -> app.execute 'background:cover'
