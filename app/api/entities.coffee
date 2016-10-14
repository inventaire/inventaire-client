{ public:publik, authentified } = require('./endpoint')('entities')

module.exports =
  search: (search)->
    options =
      action: 'search'
      search: search
      lang: app.user.lang

    _.buildPath publik, options

  get: (uris, refresh)->
    _.buildPath publik, { action: 'get-entities', uris: uris.join('|') }

  # getImages: (entityUri, data)->
  #   _.buildPath publik,
  #     action: 'get-images'
  #     entity: entityUri
  #     data: data

  reverseClaims: (property, uri)->
    _.buildPath publik, { action: 'reverse-claims', property, uri }

  authorWorks: (uri, refresh)->
    _.buildPath publik, { action: 'author-works', uri, refresh }

  inv:
    create: '/api/entities'

    claims:
      update: "#{authentified}?action=update-claim"
    labels:
      update: "#{authentified}?action=update-label"
