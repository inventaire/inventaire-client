import { noop, debounce } from 'underscore'
import { config } from '#app/config'
import { isUserId } from '#lib/boolean_tests'
import log_ from '#lib/loggers'
import { isPrerenderSession } from '#lib/metadata/update'
// Module adapted from snippet at
// https://piwik.instance/index.php?module=CoreAdminHome&action=trackingCodeGenerator&idSite=11&period=day&date=today

// expected to be a global variable by piwik.js
if (!window._paq) window._paq = []
const { _paq, env } = window

// Those handlers will be overriden once the config arrives, if tracking isn't disabled
app.commands.setHandlers({
  'track:user:id': noop,
  'track:page:view': noop,
})

export default async function () {
  if (isPrerenderSession) return
  const { piwik } = config
  if (piwik == null) return
  // - radically prevents recording development actions
  // - reduces the load on the real tracker server
  // - easier debug
  // /!\ no request is made from users recognized as admin on the piwik
  const trackerUrl = env === 'dev' ? app.API.tests : `${piwik}/piwik.php`

  _paq.push([ 'enableLinkTracking' ])
  _paq.push([ 'disableCookies' ]) // See https://matomo.org/faq/general/faq_156/
  _paq.push([ 'setTrackerUrl', trackerUrl ])
  _paq.push([ 'setSiteId', '11' ])

  // tracker will be defined once piwik.js is executed
  let tracker = null
  let piwikDisabled = false
  let piwikInitPromise

  try {
    piwikInitPromise = import('#vendor/piwik')
    await piwikInitPromise
    tracker = window.Piwik.getAsyncTracker()
  } catch (err) {
    // Known case: ublock origin
    log_.warn('Fetching Piwik failed (Could be because of a tracker blocker)', err.message)
    piwikDisabled = true
  }

  // Tracker API doc: https://developer.piwik.org/api-reference/tracking-javascript
  const setUserId = function (id) {
    if (!isUserId(id)) return

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
    'track:page:view': debounce(trackPageView, 300),
  })
}
