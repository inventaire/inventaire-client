module.exports = ->

  setCoverBg = @ui.bg.addClass.bind(@ui.bg, 'cover')
  setNormalBg = @ui.bg.removeClass.bind(@ui.bg, 'cover')

  setBackgroundFromRoute = (section)->
    if section in coverBgRoots then setCoverBg()
    else setNormalBg()

  # set background with the first route
  setBackgroundFromRoute _.currentSection()
  # then update it on route changes
  app.vent.on 'route:change', setBackgroundFromRoute

  app.commands.setHandlers
    'background:cover': setCoverBg
    'background:normal': setNormalBg

coverBgRoots = [
  'login'
  'settings'
  'signup'
  'welcome'
]