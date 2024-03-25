import { isPositiveIntegerString, isDateString } from '#lib/boolean_tests'
import decodeHtmlEntities from './decode_html_entities.ts'

export default obj => ({
  rawEntry: obj,
  isbn: getIsbn(obj),

  // Sometimes, titles and authors contains HTML entities
  // that need to be cleaned up
  // Ex: the title of https://www.librarything.com/work/347034/details/154577403
  // is exported as "Ty&ouml;p&auml;iv&auml;kirjat"
  title: decodeHtmlEntities(obj.title),
  authors: getAuthors(obj),
  publicationDate: isDateString(obj.date) ? obj.date : undefined,
  numberOfPages: isPositiveIntegerString(obj.pages) ? parseInt(obj.pages) : undefined,
  details: obj.review,
  notes: obj.privatecomment,
  libraryThingWorkId: obj.workcode,
  shelvesNames: obj.collections,
})

// TODO: parse obj.authors and assign `secondaryauthorroles`
const getAuthors = function ({ primaryauthor, authors }) {
  if (!primaryauthor) return []
  // primaryauthor is expected to be in last-first form
  // but the first-last form should be available in the authors array
  const author = authors.find(author => {
    return author.lf === primaryauthor || author.fl === primaryauthor
  })
  if (author) {
    return [ decodeHtmlEntities(author.fl) ]
  } else {
    return [ decodeHtmlEntities(primaryauthor) ]
  }
}

const getIsbn = function (obj) {
  const { isbn, ean, originalisbn } = obj
  const isbn13 = isbn?.['2']
  return isbn13 || originalisbn || ean?.[0]
}
