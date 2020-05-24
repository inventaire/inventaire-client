{ action } = require('./endpoint')('data')

module.exports =
  wikipediaExtract: (lang, title)-> action 'wp-extract', { lang, title }
  isbn: (isbn)-> action 'isbn', { isbn }
  aliases: (type, lang)-> action 'aliases', { type, lang }
