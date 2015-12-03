privat = '/api/users'
publik = '/api/users/public'

module.exports =
  data: (ids)->
    ids = _.forceArray(ids)
    if _.all ids, _.isUserId
      ids = ids.join '|'
      return "#{privat}?action=get-users&ids=#{ids}"
    else throw new Error "users data API needs an array of valid user ids"
  items: (ids)->
    ids = _.forceArray(ids)
    if ids?
      ids = ids.join '|'
      return "#{privat}?action=get-items&ids=#{ids}"
    else throw new Error "users' items API needs an id"
  search: (text)->
    _.type text, 'string'
    "/api/users/public?action=search&search=#{text}"

  searchByPosition: (latLng)->
    _.types latLng, 'numbers...'
    [lat, lng] = latLng
    return _.buildPath publik,
      action: 'search-by-position'
      lat: lat
      lng: lng
