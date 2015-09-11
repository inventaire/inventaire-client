# expected to be a global variable by piwik.js
window._paq or= []
{ _paq } = window

module.exports = ->
  _paq.push ['enableLinkTracking']
  _paq.push ['setTrackerUrl', 'https://piwik.allmende.io/piwik.php']
  _paq.push ['setSiteId', 11]

  tracker = Piwik.getAsyncTracker()

  setUserId = (id)->
    if _.isUserId id then _paq.push ['setUserId', id]

  trackPageView = (title)->
    tracker.setCustomUrl location.href
    _paq.push ['trackPageView', title]

  app.commands.setHandlers
    'track:user:id': setUserId
    # debouncing to get only one page view reported
    # when successive document:title:change occure
    # and let the time to the route to be updated
    # (app.navigate being often trigger after all the actions are done)
    'track:page:view': _.debounce trackPageView, 300
