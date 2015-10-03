module.exports = ->

  { $el } = @iconNav

  show = ->
    $el.show()
    $('main').removeClass 'no-icon-nav'

  hide = ->
    $el.hide()
    $('main').addClass 'no-icon-nav'

  @listenTo app.vent, 'route:navigate', (section)->
    if section in noIconNavRoutes then hide()
    else show()

noIconNavRoutes = [
  'welcome'
  'login'
  'signup'
]
