base = '/api/items'
publicBase = '/api/items/public'

itemsPublic = (action, query={})->
  _.buildPath publicBase, _.extend(query, { action: action })

module.exports =
  base: '/api/items'
  lastPublicItems: itemsPublic 'last-public-items'

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

  userPublicItems: (userId)->
    itemsPublic 'user-public-items',
      user: userId
