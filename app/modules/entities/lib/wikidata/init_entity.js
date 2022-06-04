import { getTextDirection } from '#lib/active_languages'
import { isNonEmptyString } from '#lib/boolean_tests'
import { buildPath } from '#lib/location'
import log_ from '#lib/loggers'
import sitelinks_ from '#lib/wikimedia/sitelinks'
import wikipedia_ from '#lib/wikimedia/wikipedia'
import getBestLangValue from '#entities/lib/get_best_lang_value'
const wdHost = 'https://www.wikidata.org'

export default function (attrs) {
  const { lang } = app.user
  setWikiLinks.call(this, lang)
  setAttributes.call(this, lang)

  this.set('isWikidataEntity', true)

  return _.extend(this, specificMethods)
}

const setWikiLinks = function (lang) {
  const updates = {
    wikidata: {
      url: `${wdHost}/entity/${this.wikidataId}`,
      wiki: `${wdHost}/wiki/${this.wikidataId}`,
      history: `${wdHost}/w/index.php?title=${this.wikidataId}&action=history`,
      merge: buildPath(`${wdHost}/wiki/Special:MergeItems`, { fromid: this.wikidataId }),
    },
  }

  // Alias on the root, as some views expect to find a history url there
  updates.history = updates.wikidata.history

  const sitelinks = this.get('sitelinks')
  if (sitelinks != null) {
    updates.wikipedia = sitelinks_.wikipedia(sitelinks, lang, this.originalLang)
    updates.wikisource = sitelinks_.wikisource(sitelinks, lang, this.originalLang)
  }
  this.set(updates)
}

const setAttributes = function (lang) {
  let label = this.get('label')
  const wikipediaTitle = this.get('wikipedia.title')
  if ((wikipediaTitle != null) && (label == null)) {
    // If no label was found, try to use the wikipedia page title
    // remove the escaped spaces: %20
    label = decodeURIComponent(wikipediaTitle)
      // Remove the eventual desambiguation part between parenthesis
      .replace(/\s\(\w+\)/, '')

    this.set('label', label)
  }

  const { value: description, lang: descriptionLang } = getBestLangValue(lang, this.originalLang, this.get('descriptions'))
  if (description != null) {
    this.set('description', description)
    this.set('descriptionLang', descriptionLang)
  }
}

const specificMethods = {
  async getWikipediaExtract () {
    // If an extract was already fetched, we are done
    if (this.get('extract') != null) return

    const lang = this.get('wikipedia.lang')
    const title = this.get('wikipedia.title')
    if ((lang == null) || (title == null)) return

    return wikipedia_.extract(lang, title)
    .then(_setWikipediaExtractAndDescription.bind(this))
    .catch(log_.Error('setWikipediaExtract err'))
  }
}

const _setWikipediaExtractAndDescription = function (extractData) {
  const { extract, lang } = extractData
  if (isNonEmptyString(extract)) {
    this.set('extractLang', lang || '')
    this.set('extractDirection', getTextDirection(lang))
    this.set('extract', extract)
  }
}
