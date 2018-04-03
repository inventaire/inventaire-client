# How to add an importer:
# - add an entry to the importers object hereafter
# - add a parser to the ./parsers folder

extractIsbnsAndFetchData = require './import/extract_isbns_and_fetch_data'

csvParser = (source)-> (data)->
  data = data.trim()
  results = window.Papa.parse data, { header: true }
  if results.errors.length > 0 then _.error results.errors, 'csv parser errors'

  results.data
  # requiring just in time to avoid preloading unnecessary parsers
  .map require("./parsers/#{source}")

importers =
  goodReads:
    format: 'csv'
    first20Characters: 'Book Id,Title,Author'
    link: 'https://www.goodreads.com/review/import'
    parse: csvParser 'good_reads'

  libraryThing:
    format: 'json'
    specificKey: 'books_id'
    link: 'https://www.librarything.com/export.php?export_type=json'
    parse: (data)->
      _.values JSON.parse(data)
      .map require('./parsers/library_thing')

  babelio:
    format: 'csv'
    encoding: 'ISO-8859-1'
    first20Characters: '"ISBN";"Titre";"Aute'
    # There seem to be several formats depending on the export time
    # and the last time I checked, the export feature wasn't working
    # making it hard to arbitrate
    disableValidation: true
    link: 'http://www.babelio.com/export.php'
    parse: csvParser 'babelio'

  ISBNs:
    format: 'all'
    help: 'any_isbn_text_file'
    parse: extractIsbnsAndFetchData

accept =
  csv: 'text/csv'
  json: 'application/json'
  all: '*/*'

prepareImporter = (name, obj)->
  obj.name = name
  obj.label = _.capitaliseFirstLetter name
  obj.accept = accept[obj.format]
  if obj.format is 'all' then obj.hideFormat = true
  return obj

for name, params of importers
  exports[name] = prepareImporter name, params
