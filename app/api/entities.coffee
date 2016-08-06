{ public:publik, authentified } = require('./endpoint')('entities')

module.exports =
  search: (search, filter)->
    options =
      action: 'search'
      search: search
      language: app.user.lang

    # WDQ-style filter
    # ex: P31:Q5
    if filter? then options.filter = filter

    _.buildPath publik, options

  getImages: (entityUri, data)->
    _.buildPath publik,
      action: 'get-images'
      entity: entityUri
      data: data
  isbns: (isbns)->
    _.buildPath publik,
      action: 'get-isbn-entities'
      isbns: _.piped(isbns)
  inv:
    create: '/api/entities'
    get: (ids)->
      _.buildPath publik,
        action: 'get-inv-entities'
        ids: _.piped(ids)

    idsByClaim: (property, value)->
      _.buildPath publik,
        action: 'ids-by-claim'
        property: property
        value: value

    claims:
      update: "#{authentified}?action=update-claim"
    labels:
      update: "#{authentified}?action=update-label"
