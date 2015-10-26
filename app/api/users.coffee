publicEndpoint = '/api/users/public'

module.exports =
  data: (ids)->
    ids = _.forceArray(ids)
    if _.all ids, _.isUserId
      ids = ids.join '|'
      return "/api/users?action=get-users&ids=#{ids}"
    else throw new Error "users data API needs an array of valid user ids"
  items: (ids)->
    ids = _.forceArray(ids)
    if ids?
      ids = ids.join '|'
      return "/api/users?action=get-items&ids=#{ids}"
    else throw new Error "users' items API needs an id"
  search: (text)->
    if text? then "/api/users/public?action=search&search=#{text}"
    else throw new Error "users' search API needs a text argument"

  searchByPosition: (latLng)->
    _.types latLng, 'numbers...'
    [lat, lng] = latLng
    return _.buildPath publicEndpoint,
      action: 'search-by-position'
      lat: lat
      lng: lng
