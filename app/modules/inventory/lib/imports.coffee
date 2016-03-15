module.exports =
  # /!\ ISO-8859 ENCODING by default
  # Copy/Paste in an empty text file to get the right encoding
  babelio: (data)->
    data
    # split by line
    .split '\n'
    # remove the headers line that should look like
    # ISBN;Titre;Auteur;Editeur;Date de publication;Date d`entrée dans Babelio;Statut;Note
    .slice 1, -1
    .map parseBabelioLine

parseBabelioLine = (line)->
  [ isbn, title, author, publisher, publicationDate, dateAddedToBabelio, status, note ] = line.split ';'

  return data =
    source: 'babelio'
    isbn: removeExtraQuotes isbn
    title: removeExtraQuotes title
    authors: removeExtraQuotes author

removeExtraQuotes = (str)->
  str
  .replace /^"/, ''
  .replace /"$/, ''
