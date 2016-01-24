base = '/api/items'
publicBase = '/api/items/public'

itemsPublic = (action, query={})->
  _.buildPath publicBase, _.extend(query, { action: action })

module.exports =
  base: '/api/items'
  lastPublicItems: (offset=0)->
    itemsPublic 'last-public-items',
      offset: offset

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
