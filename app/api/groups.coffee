{ public:publik, authentified } = require('./endpoint')('groups')
{ search, searchByPosition } = require './commons'

module.exports =
  authentified: authentified
  byId: (id)-> _.buildPath publik, { action: 'by-id', id }
  last: "#{publik}?action=last"
  search: search.bind null, publik
  searchByPosition: searchByPosition.bind null, publik
