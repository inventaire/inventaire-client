import assert_ from 'lib/assert_types'
const wdPropPrefix = 'wdt:'

export default function (lang, polyglot) {
  const modifier = (modifiers[lang] != null) ? modifiers[lang] : undefined

  return function (key, ctx) {
    // This function might be called before the tempates data arrived
    // returning '' early prevents to display undefined and make polyglot worry
    if (key == null) { return '' }
    assert_.string(key)
    // easying the transition to a property system with prefixes
    // TODO: format i18n wikidata source files to include prefixes
    // and get rid of this hack
    if (key.slice(0, 4) === wdPropPrefix) { key = key.replace(wdPropPrefix, '') }
    const val = polyglot.t(key, ctx)
    if (modifier != null) {
      return modifier(polyglot, key, val, ctx)
    } else {
      return val
    }
  }
}

const isShortkey = key => /_/.test(key)
const vowels = 'aeiouy'

const modifiers = {
  // make i18n('user_comment', { username: 'adamsberg' })
  // return "Commentaire d'adamsberg" instead of "Commentaire de adamsberg"
  fr (polyglot, key, val, data) {
    if ((data != null) && isShortkey(key)) {
      const k = polyglot.phrases[key]
      const { username } = data
      if (username != null) {
        const firstLetter = username[0].toLowerCase()
        if (vowels.includes(firstLetter)) {
          if (/(d|qu)e\s(<strong>)?%{username}/.test(k)) {
            const re = new RegExp(`(d|qu)e (<strong>)?${username}`)
            return val.replace(re, `$1'$2${username}`)
          }
        }
      }
    }

    return val
  }
}
