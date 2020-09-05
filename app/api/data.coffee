{ action } = require('./endpoint')('data')

module.exports =
  wikipediaExtract: (lang, title)-> action 'wp-extract', { lang, title }
  isbn: (isbn)-> action 'isbn', { isbn }
  entityTypeAliases: (type)-> action 'entity-type-aliases', { type }
