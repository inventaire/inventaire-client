{ base, action } = require('./endpoint')('users')
{ search, searchByPosition } = require './commons'

module.exports =
  data: (ids)-> action 'get-users', ids.join('|')
  search: search.bind null, base
  searchByPosition: searchByPosition.bind null, base
