{ public:publik, authentified } = require('./endpoint')('users')
{ search, searchByPosition } = require './commons'

module.exports =
  data: (ids)->
    ids = _.forceArray ids
    if _.all ids, _.isUserId
      ids = ids.join '|'
      return "#{publik}?action=get-users&ids=#{ids}"
    else throw new Error "users data API needs an array of valid user ids"
  search: search.bind null, publik
  searchByPosition: searchByPosition.bind null, publik

  # TODO: move to items API
  publicItemsNearby: (range=50)->
    _.buildPath authentified,
      action: 'get-items-nearby'
      range: range
