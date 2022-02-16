import { capitalize } from '#lib/utils'
import log_ from '#lib/loggers'
import libraryThingParser from './parsers/library_thing'
import goodReadsParser from './parsers/good_reads'
import babelioParser from './parsers/babelio'
import extractIsbnsAndFetchData from './import/extract_isbns_and_fetch_data'

// How to add an importer:
// - add an entry to the importers object hereafter
// - add a parser to the ./parsers folder

const csvParser = parser => function (data) {
  data = data.trim()
  const results = window.Papa.parse(data, { header: true })
  if (results.errors.length > 0) log_.error(results.errors, 'csv parser errors')

  return results.data.map(parser)
}

const importers = {
  goodReads: {
    format: 'csv',
    first20Characters: 'Book Id,Title,Author',
    link: 'https://www.goodreads.com/review/import',
    parse: csvParser(goodReadsParser)
  },

  libraryThing: {
    format: 'json',
    specificKey: 'books_id',
    link: 'https://www.librarything.com/export.php?export_type=json',
    parse (data) {
      return _.values(JSON.parse(data))
      .map(libraryThingParser)
    }
  },

  babelio: {
    format: 'csv',
    encoding: 'ISO-8859-1',
    first20Characters: '"ISBN";"Titre";"Aute',
    // There seem to be several formats depending on the export time
    // and the last time I checked, the export feature wasn't working
    // making it hard to arbitrate
    disableValidation: true,
    link: 'http://www.babelio.com/export.php',
    parse: csvParser(babelioParser)
  },

  ISBNs: {
    format: 'all',
    help: 'any_isbn_text_file',
    // Require only on demande to avoid requiring it during other importers tests
    // and thus having to adapt its dependencies to the test environment
    parse (data) { return extractIsbnsAndFetchData(data) }
  }
}

const accept = {
  csv: 'text/csv',
  json: 'application/json',
  all: '*/*'
}

const prepareImporter = function (name, obj) {
  obj.name = name
  obj.label = capitalize(name)
  obj.accept = accept[obj.format]
  if (obj.format === 'all') obj.hideFormat = true
  return obj
}

const wrappedImporters = {}

for (const name in importers) {
  const params = importers[name]
  wrappedImporters[name] = prepareImporter(name, params)
}

export default wrappedImporters
