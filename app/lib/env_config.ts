import { isObject } from 'underscore'
import { chat, wiki, apiDoc, git } from '#app/lib/urls'

// The exact env value will be returned by config
// but some functions need a value before, in case fetching the config crashes
export let detectedEnv

// Test env detection depends on whats mocked in tests/utils/mock_browser_env.ts
if (location.hostname == null) {
  detectedEnv = 'tests'
// roughtly addressing the general case
} else if (location.hostname.match(/^(localhost|\d{1,3}\.\d{1,3}\.)/)) {
  detectedEnv = 'dev'
} else {
  detectedEnv = 'prod'
}
if (detectedEnv !== 'prod') {
  const trueAlert = window.alert
  window.alert = function (obj) {
    if (isObject(obj)) obj = JSON.stringify(obj, null, 2)
    return trueAlert(obj)
  }
} else {
  console.log(`
,___,
[-.-]   I've been expecting you, Mr Bond
/)__)
-"--"-
Want to make Inventaire better? Jump in!
Project chat: ${chat}
Wiki: ${wiki}
API Documentation: ${apiDoc}
Code: ${git}/inventaire
------`)
}
