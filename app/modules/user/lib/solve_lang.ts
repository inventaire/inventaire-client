import { shortLang } from '#lib/utils'
import { langs as activeLangs } from '#lib/active_languages'
import cookie_ from 'js-cookie'

export default function (userLanguage) {
  // querystring parameters > other settings sources
  const qsLang = app.request('querystring:get', 'lang')
  let lang = qsLang || userLanguage || cookie_.get('lang') || getBrowserLocalLang()
  lang = shortLang(lang)
  if ((lang != null) && activeLangs.includes(lang)) {
    return lang
  } else {
    return 'en'
  }
}

// Adapted from: https://github.com/maxogden/browser-locale/blob/master/index.js
const getBrowserLocalLang = function () {
  // Latest versions of Chrome and Firefox set this correctly
  if (navigator.languages && navigator.languages.length) return navigator.languages[0]
  // IE only
  if (navigator.userLanguage) return navigator.userLanguage
  // Latest versions of Chrome, Firefox, and Safari set this correctly
  return navigator.language
}
