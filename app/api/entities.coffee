{ public:publik, authentified } = require('./endpoint')('entities')

CustomQuery = (action)-> (uri, refresh)->
  _.buildPath publik, { action, uri, refresh }

module.exports =
  search: (search, refresh)->
    options =
      action: 'search'
      search: search
      lang: app.user.lang
      refresh: refresh

    _.buildPath publik, options

  get: (uris, refresh)->
    _.buildPath publik,
      action: 'get-entities'
      uris: uris.join '|'
      refresh: refresh

  reverseClaims: (property, uri)->
    _.buildPath publik, { action: 'reverse-claims', property, uri }

  authorWorks: CustomQuery 'author-works'
  serieParts: CustomQuery 'serie-parts'

  changes: -> _.buildPath publik, { action: 'get-changes' }

  create: '/api/entities'

  claims:
    update: "#{authentified}?action=update-claim"
  labels:
    update: "#{authentified}?action=update-label"
