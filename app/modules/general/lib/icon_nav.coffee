module.exports = ->

  { $el } = @iconNav

  show = ->
    $el.show()
    $('main').addClass 'icon-nav-shown'

  hide = ->
    $el.hide()
    $('main').removeClass 'icon-nav-shown'

  @listenTo app.vent, 'route:change', (section)->
    if section in noIconNavRoutes then hide()
    else show()

noIconNavRoutes = [
  'welcome'
  'login'
  'signup'
]
