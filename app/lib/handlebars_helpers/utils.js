import { isNonEmptyArray } from 'lib/boolean_tests'
import log_ from 'lib/loggers'
import { fixedEncodeURIComponent } from 'lib/utils'
// inspired by some things there http://assemble.io/helpers/
import { SafeString, escapeExpression } from 'handlebars'

export default {
  join (array, separator) {
    if (!isNonEmptyArray(array)) { return array }
    if (!_.isString(separator)) { separator = ', ' }
    return array.join(separator)
  },

  joinAuthors (array) {
    array = _.compact(array)
    if (array?.length <= 0) { return '' }
    return new SafeString(this.join(array.map(linkifyAuthorString)) + '<br>')
  },

  log (args, data) { return log_.info.apply(_, args) },

  default (text, def) { return text || def }
}

const linkifyAuthorString = function (text) {
  const str = escapeExpression(text)
  const q = fixedEncodeURIComponent(text)
  return `<a href='/search?q=${q}' class='link searchAuthor'>${str}</a>`
}
