{ action } = require('./endpoint')('entities')

CustomQuery = (actionName)-> (uri, refresh)-> action actionName, { uri, refresh }

module.exports =
  # GET
  search: (search, refresh, fast)->
    { lang } = app.user
    action 'search', { search, lang, refresh, fast }

  searchLocal: (type, search)-> action 'search-local', { type, search }

  get: (uris, refresh)->
    uris = uris.join '|'
    action 'by-uris', { uris, refresh }

  reverseClaims: (property, uri)-> action 'reverse-claims', { property, uri }

  authorWorks: CustomQuery 'author-works'
  serieParts: CustomQuery 'serie-parts'

  changes: action 'changes'
  history: (id)-> action 'history', { id }

  # POST
  create: action 'create'
  existsOrCreateFromSeed: action 'exists-or-create-from-seed'

  # PUT
  claims:
    update: action 'update-claim'

  labels:
    update: action 'update-label'

  # (ADMIN)
  merge: action 'merge'
