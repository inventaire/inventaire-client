import Handlebars from 'handlebars/runtime.js'
import { isNonEmptyArray } from '#lib/boolean_tests'
import log_ from '#lib/loggers'
import { fixedEncodeURIComponent } from '#lib/utils'

const { SafeString, escapeExpression } = Handlebars

// Inspired by some things there https://assemble.io/helpers/

export default {
  join (array, separator) {
    if (!isNonEmptyArray(array)) return array
    if (!_.isString(separator)) separator = ', '
    return array.join(separator)
  },

  joinAuthors (array) {
    array = _.compact(array)
    if (array?.length <= 0) return ''
    return new SafeString(this.join(array.map(linkifyAuthorString)) + '<br>')
  },

  log (args) { return log_.info.apply(_, args) },

  default (text, def) { return text || def },
}

const linkifyAuthorString = function (text) {
  const str = escapeExpression(text)
  const q = fixedEncodeURIComponent(text)
  return `<a href='/search?q=${q}' class='link searchAuthor'>${str}</a>`
}
