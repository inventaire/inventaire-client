module.exports = ->
  { $el } = @iconNav

  show = ->
    $el.show()
    $('main').addClass 'icon-nav-shown'

  hide = ->
    $el.hide()
    $('main').removeClass 'icon-nav-shown'

  updateBySection = (section)->
    if section in noIconNavRoutes then hide()
    else show()

  updateBySection _.currentSection()
  @listenTo app.vent, 'route:change', updateBySection

noIconNavRoutes = [
  'welcome'
  'login'
  'signup'
]
