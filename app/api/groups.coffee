{ public:publik, authentified } = require('./endpoint')('groups')
{ search, searchByPosition } = require './commons'

module.exports =
  authentified: authentified
  public: publik
  last: "#{publik}?action=last"
  search: search.bind null, publik
  searchByPosition: searchByPosition.bind null, publik
