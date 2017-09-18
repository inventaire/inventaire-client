# Instead of the normal app layout, display a screen
# inviting to install a modern browser
OldBrowserScreen = Marionette.LayoutView.extend
  el: '#app'
  template: require './templates/old_browser_screen'
  initialize: -> @render()
  onRender: -> @$el.addClass 'old-browser-screen'

module.exports = -> require('init_app').init -> new OldBrowserScreen()
