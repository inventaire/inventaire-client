{ base, action } = require('./endpoint')('entities')

CustomQuery = (actionName)-> (uri, refresh)-> action actionName, { uri, refresh }

module.exports =
  # GET
  search: (search, refresh)->
    action 'search', { search, lang: app.user.lang, refresh }

  get: (uris, refresh)->
    uris = uris.join '|'
    action 'get-entities', { uris, refresh }

  reverseClaims: (property, uri)-> action 'reverse-claims', { property, uri }

  authorWorks: CustomQuery 'author-works'
  serieParts: CustomQuery 'serie-parts'

  changes: action 'get-changes'
  history: (id)-> action 'history', { id }

  # POST/PUT
  create: base

  existsOrCreateFromSeed: action 'exists-or-create-from-seed'

  claims:
    update: action 'update-claim'

  labels:
    update: action 'update-label'

  # ADMIN
  merge: action 'merge'
