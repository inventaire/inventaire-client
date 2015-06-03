module.exports = ->

  { $el } = @iconNav

  show = ->
    $el.show()
    $('main').removeClass 'no-icon-nav'

  hide = ->
    $el.hide()
    $('main').addClass 'no-icon-nav'

  app.commands.setHandlers
    'icon:nav:show': show
    'icon:nav:hide': hide

  @listenTo app.vent, 'route:navigate', (section)->
    if section in noIconNavRoutes then hide()


noIconNavRoutes = [
  'welcome'
  'login'
  'signup'
]
