import Handlebars from 'handlebars/runtime.js'
import { API } from '#app/api/api'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'
import { i18n } from '#user/lib/i18n'

// @ts-expect-error
const { escapeExpression } = Handlebars

export default {
  extract (lang, title) {
    return preq.get(API.data.wikipediaExtract(lang, title))
    .then(data => {
      let { extract, url } = data
      lang = url?.match(/^https:\/\/([\w-]+).wik/)?.[1]
      // Escaping as extracts are user-generated external content
      // that will be displayed as {{{SafeStrings}}} in views as
      // they are enriched with HTML by sourcedExtract hereafter
      extract = escapeExpression(extract)
      extract = sourcedExtract(extract, url)
      return { extract, lang }
    })
    .catch(log_.ErrorRethrow('wikipediaExtract err'))
  },
}

// Add a link to the full wikipedia article at the end of the extract
const sourcedExtract = function (extract, url) {
  if ((extract != null) && (url != null)) {
    const text = i18n('read_more_on_wikipedia')
    extract += `<br><a href="${url}" class='source link' target='_blank'>${text}</a>`
  }

  return extract
}
