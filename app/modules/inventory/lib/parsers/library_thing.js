import { isPositiveIntegerString, isNonNull, isDateString } from '#lib/boolean_tests'

import decodeHtmlEntities from './decode_html_entities'

export default obj => ({
  isbn: getIsbn(obj),

  // Sometimes, titles and authors contains HTML entities
  // that need to be cleaned up
  // Ex: the title of https://www.librarything.com/work/347034/details/154577403
  // is exported as "Ty&ouml;p&auml;iv&auml;kirjat"
  title: decodeHtmlEntities(obj.title),

  authors: getAuthorsString(obj),
  publicationDate: isDateString(obj.date) ? obj.date : undefined,
  numberOfPages: isPositiveIntegerString(obj.pages) ? parseInt(obj.pages) : undefined,
  libraryThingWorkId: obj.workcode
})

const getAuthorsString = function (obj) {
  const { authors } = obj
  if (!_.isArray(authors) || (authors.length <= 0)) return

  return authors
  .map(_.property('fl'))
  .filter(isNonNull)
  .map(decodeHtmlEntities)
}

const getIsbn = function (obj) {
  const { isbn, ean, originalisbn } = obj
  const isbn13 = isbn?.['2']
  return isbn13 || originalisbn || ean?.[0]
}
