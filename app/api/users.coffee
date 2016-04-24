privat = '/api/users'
publik = '/api/users/public'

{ search, searchByPosition } = require './commons'

module.exports =
  data: (ids)->
    ids = _.forceArray ids
    if _.all ids, _.isUserId
      ids = ids.join '|'
      return "#{publik}?action=get-users&ids=#{ids}"
    else throw new Error "users data API needs an array of valid user ids"
  items: (ids)->
    ids = _.forceArray ids
    if ids?
      ids = ids.join '|'
      return "#{privat}?action=get-users-items&ids=#{ids}"
    else throw new Error "users' items API needs an id"
  search: search.bind null, publik
  searchByPosition: searchByPosition.bind null, publik

  publicItemsNearby: (range=50)->
    _.buildPath privat,
      action: 'get-items-nearby'
      range: range
