import { langs, regionify } from 'lib/active_languages'
import { setQuerystring, currentRoute } from 'lib/location'
const { origin } = location

// lang metadata updates needed by search engines
// or to make by-language css rules (with :lang)
export default function ($app, lang) {
  setAppLang($app, lang)

  const elements = []
  addAlternateLangs(elements, addOgLocalAlternates(elements, lang))
  return $('head').append(elements.join(''))
}

const setAppLang = ($app, lang) => $app.attr('lang', lang)

const addAlternateLangs = function (elements) {
  const href = `${origin}/${currentRoute()}`
  // Non-default langs needing a lang querystring
  for (const lang of langs) {
    if (lang !== 'en') addHreflang(elements, href, true, lang)
  }
  // The default lang - en - doesnt need a lang querystring to be set.
  // It could have one, but search engines need to know that the default url
  // they got matches this languages hreflang
  return addHreflang(elements, href, false, 'en')
}

const addHreflang = function (elements, href, withLangQueryString, lang) {
  // Can't use location.href directly as it seems
  // to be updated after route:navigate
  // Discarding querystring to only keep lang
  if (withLangQueryString) href = setQuerystring(href, 'lang', lang)
  return elements.push(`<link rel='alternate' href='${href}' hreflang='${lang}' />`)
}

const addOgLocalAlternates = function (elements, lang) {
  // set the current lang as 'og:locale'
  const local = regionify[lang]
  elements.push(`<meta property='og:locale' content='${local}' />`)

  // set the others as 'og:locale:alternate'
  const otherTerritories = _.values(_.omit(regionify, lang))
  return otherTerritories.map(territory => elements.push(`<meta property='og:locale:alternate' content='${territory}' />`))
}
