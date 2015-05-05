module.exports = ->

  { $el } = @iconNav

  show = $el.show.bind($el)
  hide = $el.hide.bind($el)

  app.commands.setHandlers
    'icon:nav:show': show
    'icon:nav:hide': hide

  @listenTo app.vent, 'route:navigate', (route)->
    root = route.split('/')[0]
    if root in noIconNavRoutes then hide()


noIconNavRoutes = [
  'welcome'
  'login'
  'signup'
]
