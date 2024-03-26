import { isObject } from 'underscore'
import { chat, wiki, apiDoc, git } from '#lib/urls'

// roughtly addressing the general case
if (location.hostname.match(/^(localhost|\d{1,3}\.\d{1,3}\.)/)) {
  window.env = 'dev'
} else {
  window.env = 'prod'
}

if (window.env === 'dev') {
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
