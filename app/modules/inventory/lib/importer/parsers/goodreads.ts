import { compact } from 'underscore'
import { isPositiveIntegerString, isDateString } from '#lib/boolean_tests'
import { trim, capitalize } from '#lib/utils'

export default obj => ({
  rawEntry: obj,
  title: obj.Title,
  isbn: cleanIsbn(obj.ISBN13 || obj.ISBN),
  authors: obj.Author.split(',').map(trim),
  details: obj['My Review'],
  publisher: obj.Publisher,
  publicationDate: isDateString(obj['Year Published']) ? obj['Year Published'] : undefined,
  numberOfPages: isPositiveIntegerString(obj['Number of Pages']) ? parseInt(obj['Number of Pages']) : undefined,
  notes: obj['Private Notes'],
  // See https://www.goodreads.com/api/index#book.id_to_work_id
  goodReadsEditionId: obj['Book Id'],
  shelvesNames: formatShelvesNames(obj.Bookshelves),
})

const cleanIsbn = isbn => isbn?.replace(/("|=)/g, '')

const formatShelvesNames = bookshelves => compact(bookshelves.split(',').map(formatShelfName))

const formatShelfName = name => capitalize(trim(name.replace(/-/g, ' ')))
