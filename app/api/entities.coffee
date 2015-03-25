module.exports =
  search: (search)->
    _.buildPath "/api/entities/public",
      action: 'search'
      search: search
      language: app.user.lang
  getImages: (data)->
    _.buildPath "/api/entities/public",
      action: 'getimages'
      data: _.piped(data)
  isbns: (isbns)->
    _.buildPath '/api/entities/public',
      action: 'getisbnentities'
      isbns: _.piped(isbns)
  inv:
    create: '/api/entities'
    get: (ids)->
      _.buildPath '/api/entities', { ids: _.piped(ids) }
  followed: '/api/entities/followed'