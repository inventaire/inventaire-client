module.exports = (line)->
  [ isbn, title, author, publisher, publicationDate, dateAddedToBabelio, status, note ] = line.split ';'

  return data =
    isbn: removeExtraQuotes isbn
    title: removeExtraQuotes title
    authors: removeExtraQuotes author

removeExtraQuotes = (str)->
  str
  .replace /^"/, ''
  .replace /"$/, ''
