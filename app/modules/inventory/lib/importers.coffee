csvParser = (source, data)->
  data
  # split by line
  .split '\n'
  # remove the headers line
  .slice 1, -1
  # requiring just in time to avoid preloading unnecessary parsers
  .map require("./parsers/#{source}")

importers =
  goodReads:
    format: 'csv'
    encoding: 'UTF-8'
    first20Characters: 'Book Id,Title,Author'
    link: 'https://www.goodreads.com/review/import'
    parse: csvParser.bind(null, 'good_reads')

  libraryThing:
    format: 'json'
    encoding: 'UTF-8'
    specificKey: 'books_id'
    link: 'https://www.librarything.com/export.php?export_type=json'
    parse: (data)->
      _.values JSON.parse(data)
      .map require('./parsers/library_thing')

  babelio:
    format: 'csv'
    encoding: 'ISO-8859-1'
    first20Characters: '"ISBN";"Titre";"Aute'
    link: 'http://www.babelio.com/export.php'
    parse: csvParser.bind(null, 'babelio')

accept =
  csv: 'text/csv'
  json: 'application/json'

format = (id, obj)->
  obj.id = id
  obj.label = _.capitaliseFirstLetter id
  obj.accept = accept[obj.format]
  return obj

for k, v of importers
  exports[k] = format k, v
