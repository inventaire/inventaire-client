{ base, action } = require('./endpoint')('groups')
{ search, searchByPosition } = require './commons'

module.exports =
  base: base
  byId: (id)-> action 'by-id', { id }
  last: action 'last'
  search: search.bind null, base
  searchByPosition: searchByPosition.bind null, base
