module.exports =
  goodReads: (data)->
    commonCsvParser data
    .map parseGoodReadsLine

  babelio: (data)->
    commonCsvParser data
    .map parseBabelioLine

commonCsvParser = (data)->
  data
  # split by line
  .split '\n'
  # remove the headers line
  .slice 1, -1

# Book Id,Title,Author,Author l-f,Additional Authors,ISBN,ISBN13,My Rating,Average Rating,Publisher,Binding,Number of Pages,Year Published,Original Publication Year,Date Read,Date Added,Bookshelves,Bookshelves with positions,Exclusive Shelf,My Review,Spoiler,Private Notes,Read Count,Recommended For,Recommended By,Owned Copies,Original Purchase Date,Original Purchase Location,Condition,Condition Description,BCID
parseGoodReadsLine = (line)->
  # nullifying allows to use 'or'
  line = substituteValidCommas line
  _.log line, 'line after substituteValidCommas'
  values = line.split(',')
    .map replaceCommaPlaceholder
    .map nullifyEmptyString

  return data =
    source: 'goodReads'
    isbn: getIsbn values
    title: values[1]
    authors: values[2]
    notes: values[21]

getIsbn = (values)->
  isbn = values[6] or values[5]
  # isbns look like "=""9780061709715"""
  if isbn? then return isbn.replace /("|=)/g, ''

# some values have an internal comma (ex: "Tapscott, Don")
# that we replaced by the improbable characters chain §@§
# so that we can recover it after having split on commas
substituteValidCommas = (line)->
  return line.replace /,"([^"]+),([^"]+)",/g, ",$1§@§$2,"

replaceCommaPlaceholder = (line)->
  console.log 'line', line
  return line.replace /§@§/g, ','

commaPlaceholder = '§@§'

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

nullifyEmptyString = (str)-> if str is '' then null else str
