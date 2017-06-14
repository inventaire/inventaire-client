exports.import = ->
  require('./js/modernizr.js')
  require('./js/foundation.js')
  require('./js/foundation.alert.js')
  require('./js/foundation.dropdown.js')
  require('./js/foundation.joyride.js')
  require('./js/foundation.topbar.js')

exports.initialize = (app)->
  app.commands.setHandlers
    'foundation:reload': _.debounce foundationReload, 50
    'foundation:joyride:start': startJoyride

foundationReload = (options)->
  # first called on account menu show
  $(document).foundation options
  app.vent.trigger 'foundation:reload'

startJoyride = (options)->
  $(document).foundation(options).foundation 'joyride', 'start'
