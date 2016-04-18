module.exports =
  search: (search, filter)->
    options =
      action: 'search'
      search: search
      language: app.user.lang

    # WDQ-style filter
    # ex: P31:Q5
    if filter? then options.filter = filter

    _.buildPath '/api/entities/public', options

  getImages: (entityUri, data)->
    _.buildPath '/api/entities/public',
      action: 'get-images'
      entity: entityUri
      data: data
  isbns: (isbns)->
    _.buildPath '/api/entities/public',
      action: 'get-isbn-entities'
      isbns: _.piped(isbns)
  inv:
    create: '/api/entities'
    get: (ids)->
      _.buildPath '/api/entities/public',
        action: 'get-inv-entities'
        ids: _.piped(ids)
