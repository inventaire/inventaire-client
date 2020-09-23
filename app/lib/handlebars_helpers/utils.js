// inspired by some things there http://assemble.io/helpers/
const { SafeString, escapeExpression } = Handlebars

export default {
  join (array, separator) {
    if (!_.isNonEmptyArray(array)) { return array }
    if (!_.isString(separator)) { separator = ', ' }
    return array.join(separator)
  },

  joinAuthors (array) {
    array = _.compact(array)
    if (array?.length <= 0) { return '' }
    return new SafeString(this.join(array.map(linkifyAuthorString)) + '<br>')
  },

  log (args, data) { return _.log.apply(_, args) },

  default (text, def) { return text || def }
}

var linkifyAuthorString = function (text) {
  const str = escapeExpression(text)
  const q = _.fixedEncodeURIComponent(text)
  return `<a href='/search?q=${q}' class='link searchAuthor'>${str}</a>`
}
