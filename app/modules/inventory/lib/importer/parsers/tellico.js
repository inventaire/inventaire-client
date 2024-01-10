import { isPositiveIntegerString } from '#lib/boolean_tests'

export default obj => ({
  rawEntry: obj,
  title: obj.Titre,
  isbn: cleanIsbn(obj['ISBN#']),
  authors: [ obj.Auteur ],
  publisher: obj["Maison d'édition"],
  publicationDate: obj['Année de publication'],
  numberOfPages: isPositiveIntegerString(obj.Pages) ? parseInt(obj.Pages) : undefined,
  notes: obj.Notes,
})

const cleanIsbn = isbn => isbn?.replace(/("|=)/g, '')
