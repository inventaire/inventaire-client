module.exports = ->

  setCoverBg = @ui.bg.addClass.bind(@ui.bg, 'cover')
  setNormalBg = @ui.bg.removeClass.bind(@ui.bg, 'cover')

  setBackgroundFromRoute = (route)->
    root = route.split('/')[0]
    console.log 'route', route, root
    if root in coverBgRoots then setCoverBg()
    else setNormalBg()

  # set background with the first route
  setBackgroundFromRoute location.pathname.slice(1)
  # then update it on route changes
  app.vent.on 'route:navigate', setBackgroundFromRoute

  app.commands.setHandlers
    'background:cover': setCoverBg
    'background:normal': setNormalBg


coverBgRoots = [
  'login'
  'settings'
  'signup'
  'welcome'
]