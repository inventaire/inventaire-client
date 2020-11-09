import { chat, wiki, roadmap, git } from 'lib/urls'

// roughtly addressing the general case
if (location.hostname.match(/^(localhost|192\.168)/)) {
  window.env = 'dev'
} else {
  window.env = 'prod'
}

if (window.env === 'dev') {
  const trueAlert = window.alert
  window.alert = function (obj) {
    if (_.isObject(obj)) obj = JSON.stringify(obj, null, 2)
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
Design: ${roadmap}
Code: ${git}/inventaire
------`)
}
