{ action } = require('./endpoint')('bookshelves')

module.exports =
  byIds: (ids)-> action 'by-ids', { ids, 'with-items': true }
