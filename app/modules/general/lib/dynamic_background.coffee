screen_ = require 'lib/screen'
{ currentSection } = require 'lib/location'

module.exports = ->
  setCoverBg = @ui.bg.addClass.bind(@ui.bg, 'cover')
  setNormalBg = @ui.bg.removeClass.bind(@ui.bg, 'cover')

  setBackgroundFromRoute = (section)->
    if section in coverBgRoots
      setCoverBg()
    else if not screen_.isSmall() and section in coverBgOnLargeScreenRoots
      setCoverBg()
    else
      setNormalBg()

  # set background with the first route
  setBackgroundFromRoute currentSection()
  # then update it on route changes
  app.vent.on 'route:change', setBackgroundFromRoute

  app.commands.setHandlers
    'background:cover': setCoverBg
    'background:normal': setNormalBg

coverBgRoots = [
  'welcome'
]

coverBgOnLargeScreenRoots = [
  'login'
  'signup'
  'settings'
]
