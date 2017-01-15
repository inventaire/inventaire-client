{ public:publik, authentified } = require('./endpoint')('entities')

CustomQuery = (action)-> (uri, refresh)->
  _.buildPath publik, { action, uri, refresh }

module.exports =
  # GET
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
  history: (id)-> _.buildPath publik, { action: 'history', id }

  # POST/PUT
  create: authentified

  existsOrCreateFromSeed: "#{authentified}?action=exists-or-create-from-seed"

  claims:
    update: "#{authentified}?action=update-claim"

  labels:
    update: "#{authentified}?action=update-label"

  # ADMIN
  merge: "#{authentified}/admin?action=merge"
