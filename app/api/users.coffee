{ base, action } = require('./endpoint')('users')
{ search, searchByPosition } = require './commons'

module.exports =
  byIds: (ids)-> action 'by-ids', { ids: ids.join('|') }
  byUsername: (username)-> action 'by-usernames', { usernames: username }
  search: search.bind null, base
  searchByPosition: searchByPosition.bind null, base
