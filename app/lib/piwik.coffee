# Module adapted from snippet at
# https://piwik.instance/index.php?module=CoreAdminHome&action=trackingCodeGenerator&idSite=11&period=day&date=today

# expected to be a global variable by piwik.js
window._paq or= []
{ _paq, env } = window

module.exports = ->
  { piwik } = app.config
  # - radically prevents recording development actions
  # - reduces the load on the real tracker server
  # - easier debug
  # /!\ no request is made from users recognized as admin on the piwik
  trackerUrl = if env is 'dev' then app.API.tests else "#{piwik}/piwik.php"

  _paq.push ['enableLinkTracking']
  _paq.push ['setTrackerUrl', trackerUrl]
  _paq.push ['setSiteId', '11']

  # tracker will be defined once piwik.js is executed
  tracker = null
  piwikDisabled = false

  # Unfortunately, piwik.js can't be bundled within vendor.js
  # as it has to be run after _paq is initialized (here above)
  piwikInitPromise = _.preq.getScript app.API.assets.scripts.piwik()
    .then -> tracker = Piwik.getAsyncTracker()
    .catch (err)->
      # Known case: ublock origin
      _.warn 'Fetching Piwik failed (Could be because of a tracker blocker)'
      piwikDisabled = true

  # Tracker API doc: http://developer.piwik.org/api-reference/tracking-javascript
  setUserId = (id)->
    unless _.isUserId(id) then return

    piwikInitPromise
    .then -> unless piwikDisabled then tracker.setUserId id

  trackPageView = (title)->
    if piwikDisabled then return

    piwikInitPromise
    .then ->
      # piwikDisabled might have been toggled after a failed initialization
      if piwikDisabled then return
      tracker.setCustomUrl location.href
      tracker.trackPageView title

  app.commands.setHandlers
    'track:user:id': setUserId
    # debouncing to get only one page view reported
    # when successive document:title:change occure
    # and let the time to the route to be updated
    # (app.navigate being often trigger after all the actions are done)
    'track:page:view': _.debounce trackPageView, 300
