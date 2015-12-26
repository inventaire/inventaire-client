privat = '/api/groups'
publik = '/api/groups/public'

{ search, searchByPosition } = require './commons'

module.exports =
  private: privat
  public: publik
  last: "#{publik}?action=last"
  search: search.bind null, publik
  searchByPosition: searchByPosition.bind null, publik
