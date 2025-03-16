import type { UserLang } from '#app/lib/active_languages'
import assert_ from '#app/lib/assert_types'
import { isWikidataPropertyId } from '#app/lib/boolean_tests'
import type Polyglot from 'node-polyglot'

const wdPropPrefix = 'wdt:'

export default function (lang: UserLang, polyglot: Polyglot) {
  const modifier = (modifiers[lang] != null) ? modifiers[lang] : undefined

  return function (key: string, ctx?: Polyglot.InterpolationOptions) {
    // This function might be called before the tempates data arrived
    // returning '' early prevents to display undefined and make polyglot worry
    if (key == null) return ''
    assert_.string(key)
    // easying the transition to a property system with prefixes
    // TODO: format i18n wikidata source files to include prefixes
    // and get rid of this hack
    if (key.slice(0, 4) === wdPropPrefix) key = key.replace(wdPropPrefix, '')
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
const isFrenchGenderedRole = val => /\w+eur ou \w+(ice|euse)/.test(val)

const modifiers = {
  fr (polyglot, key, val, data) {
    // Make i18n('user_comment', { username: 'adamsberg' })
    // return "Commentaire d'adamsberg" instead of "Commentaire de adamsberg"
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
    // Make i18n('P50') return "auteur·ice" instead of "auteur ou autrice"
    } else if (isWikidataPropertyId(key) && isFrenchGenderedRole(val)) {
      return val
      .replace(/ ou \w+ice$/, '·ice')
      .replace(/ ou \w+euse$/, '·euse')
    }

    return val
  },
}
