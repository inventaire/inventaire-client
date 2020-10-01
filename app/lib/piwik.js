import preq from 'lib/preq'
// Module adapted from snippet at
// https://piwik.instance/index.php?module=CoreAdminHome&action=trackingCodeGenerator&idSite=11&period=day&date=today

// expected to be a global variable by piwik.js
if (!window._paq) window._paq = []
const { _paq, env } = window
const isPrerenderSession = (window.navigator.userAgent.match('Prerender') != null)

export default function () {
  if (isPrerenderSession) return
  const { piwik } = app.config
  if (piwik == null) return
  // - radically prevents recording development actions
  // - reduces the load on the real tracker server
  // - easier debug
  // /!\ no request is made from users recognized as admin on the piwik
  const trackerUrl = env === 'dev' ? app.API.tests : `${piwik}/piwik.php`

  _paq.push([ 'enableLinkTracking' ])
  _paq.push([ 'setTrackerUrl', trackerUrl ])
  _paq.push([ 'setSiteId', '11' ])

  // tracker will be defined once piwik.js is executed
  let tracker = null
  let piwikDisabled = false

  // Unfortunately, piwik.js can't be bundled within vendor.js
  // as it has to be run after _paq is initialized (here above)
  const piwikInitPromise = preq.getScript(app.API.assets.scripts.piwik())
    .then(() => { tracker = window.Piwik.getAsyncTracker() })
    .catch(err => {
      // Known case: ublock origin
      _.warn('Fetching Piwik failed (Could be because of a tracker blocker)', err.message)
      piwikDisabled = true
    })

  // Tracker API doc: http://developer.piwik.org/api-reference/tracking-javascript
  const setUserId = function (id) {
    if (!_.isUserId(id)) return

    return piwikInitPromise
    .then(() => {
      if (!piwikDisabled) return tracker.setUserId(id)
    })
  }

  const trackPageView = function (title) {
    if (piwikDisabled) return

    return piwikInitPromise
    .then(() => {
      // piwikDisabled might have been toggled after a failed initialization
      if (piwikDisabled) return
      tracker.setCustomUrl(location.href)
      return tracker.trackPageView(title)
    })
    .catch(err => {
      // Known error with unidentified cause
      if (err.message === 'dataElement is null') return
      throw err
    })
  }

  app.commands.setHandlers({
    'track:user:id': setUserId,
    // debouncing to get only one page view reported
    // when successive document:title:change occure
    // and let the time to the route to be updated
    // (app.navigate being often trigger after all the actions are done)
    'track:page:view': _.debounce(trackPageView, 300)
  })
};
