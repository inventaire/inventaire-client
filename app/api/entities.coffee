{ public:publik, authentified } = require('./endpoint')('entities')

CustomQuery = (action)-> (uri, refresh)->
  _.buildPath publik, { action, uri, refresh }

module.exports =
  search: (search)->
    options =
      action: 'search'
      search: search
      lang: app.user.lang

    _.buildPath publik, options

  get: (uris, refresh)->
    _.buildPath publik,
      action: 'get-entities'
      uris: uris.join '|'
      refresh: refresh

  # getImages: (entityUri, data)->
  #   _.buildPath publik,
  #     action: 'get-images'
  #     entity: entityUri
  #     data: data

  reverseClaims: (property, uri)->
    _.buildPath publik, { action: 'reverse-claims', property, uri }

  authorWorks: CustomQuery 'author-works'
  serieParts: CustomQuery 'serie-parts'

  inv:
    create: '/api/entities'

    claims:
      update: "#{authentified}?action=update-claim"
    labels:
      update: "#{authentified}?action=update-label"
