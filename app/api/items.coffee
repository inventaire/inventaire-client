base = '/api/items'
publicBase = '/api/items/public'

itemsPublic = (action, query={})->
  _.buildPath publicBase, _.extend(query, { action: action })

module.exports =
  base: base
  lastPublicItems: (limit=15, offset=0, assertImage)->
    itemsPublic 'last-public-items',
      limit: limit
      offset: offset
      'assert-image': assertImage

  publicNearby: (range=50)->
    _.buildPath base,
      action: 'get-items-nearby'
      range: range

  publicById: (id)->
    itemsPublic 'public-by-id',
      id: id

  publicByEntity: (uri)->
    itemsPublic 'public-by-entity',
      uri: uri

  publicByUsernameAndEntity: (username, EntityUri)->
    itemsPublic 'public-by-username-and-entity',
      username: username
      uri: EntityUri

  usersPublicItems: (usersIds)->
    usersIds = _.forceArray usersIds
    itemsPublic 'users-public-items',
      users: usersIds.join('|')
