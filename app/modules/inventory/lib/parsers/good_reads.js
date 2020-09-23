export default obj => ({
  title: obj.Title,
  isbn: cleanIsbn(obj.ISBN13 || obj.ISBN),
  authors: obj.Author.split(',').map(_.trim),
  details: obj['My Review'],
  publisher: obj.Publisher,
  publicationDate: _.isDateString(obj['Year Published']) ? obj['Year Published'] : undefined,
  numberOfPages: _.isPositiveIntegerString(obj['Number of Pages']) ? parseInt(obj['Number of Pages']) : undefined,

  // See https://www.goodreads.com/api/index#book.id_to_work_id
  goodReadsEditionId: obj['Book Id']
})

var cleanIsbn = isbn => isbn?.replace(/("|=)/g, '')
