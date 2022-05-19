import { isPositiveIntegerString, isDateString } from '#lib/boolean_tests'
import { forceArray } from '#lib/utils'

import decodeHtmlEntities from './decode_html_entities.js'

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
  details: obj.review,
  notes: obj.privatecomment,
  libraryThingWorkId: obj.workcode
})

const getAuthorsString = function (obj) {
  // TODO: parse obj.authors and assign `secondaryauthorroles`
  return forceArray(decodeHtmlEntities(obj.primaryauthor))
}

const getIsbn = function (obj) {
  const { isbn, ean, originalisbn } = obj
  const isbn13 = isbn?.['2']
  return isbn13 || originalisbn || ean?.[0]
}
