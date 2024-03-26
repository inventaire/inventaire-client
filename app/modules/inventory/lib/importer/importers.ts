import Papa from 'papaparse'
import { extractIsbns } from '#inventory/lib/importer/extract_isbns'
import log_ from '#lib/loggers'
import { capitalize } from '#lib/utils'
import babelioParser from './parsers/babelio.ts'
import goodReadsParser from './parsers/goodreads.ts'
import libraryThingParser from './parsers/library_thing.ts'

// How to add an importer:
// - add an entry to the importers object hereafter
// - add a parser to the ./parsers folder

const csvParser = parser => function (data) {
  data = data.trim()
  const results = Papa.parse(data, { header: true })
  if (results.errors.length > 0) log_.error(results.errors, 'csv parser errors')

  return results.data.map(parser)
}

const importers = {
  goodReads: {
    format: 'csv',
    first20Characters: 'Book Id,Title,Author',
    link: 'https://www.goodreads.com/review/import',
    parse: csvParser(goodReadsParser),
  },

  libraryThing: {
    format: 'json',
    specificKey: 'books_id',
    link: 'https://www.librarything.com/export.php?export_type=json',
    parse (data) {
      return Object.values(JSON.parse(data))
      .map(libraryThingParser)
    },
  },

  babelio: {
    format: 'csv',
    encoding: 'ISO-8859-1',
    first20Characters: '"ISBN";"Titre";"Aute',
    help: 'library_or_critic',
    link: 'http://www.babelio.com/export.php',
    parse: csvParser(babelioParser),
  },

  ISBNs: {
    format: 'all',
    help: 'any_isbn_text_file',
    // Require only on demande to avoid requiring it during other importers tests
    // and thus having to adapt its dependencies to the test environment
    parse (isbnsText) {
      const isbnsData = extractIsbns(isbnsText).filter(isbnData => !isbnData.isInvalid)
      return isbnsData.map(isbnData => { return { isbnData } })
    },
  },
}

const accept = {
  csv: 'text/csv',
  json: 'application/json',
  all: '*/*',
}

const prepareImporter = function (name, obj) {
  obj.name = name
  obj.label = capitalize(name)
  obj.accept = accept[obj.format]
  if (obj.format === 'all') obj.hideFormat = true
  return obj
}

const wrappedImporters = []

for (const name in importers) {
  const params = importers[name]
  wrappedImporters.push(prepareImporter(name, params))
}

export default wrappedImporters
