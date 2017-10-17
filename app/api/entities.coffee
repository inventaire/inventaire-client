{ action } = require('./endpoint')('entities')

CustomQuery = (actionName)-> (uri, refresh)-> action actionName, { uri, refresh }

module.exports =
  # GET
  search: (search, refresh, fast)->
    { lang } = app.user
    action 'search', { search, lang, refresh, fast }

  searchType: (type, search, limit)-> action 'search-type', { type, search, limit }

  get: (uris, refresh)->
    uris = uris.join '|'
    action 'by-uris', { uris, refresh }

  reverseClaims: (property, uri, refresh, sort)->
    action 'reverse-claims', { property, uri, refresh, sort }

  authorWorks: CustomQuery 'author-works'
  serieParts: CustomQuery 'serie-parts'

  activity: (period)-> action 'activity', { period }
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
  duplicates: action 'duplicates'
  contributions: (userId, limit, offset)->
    action 'contributions', { user: userId, limit, offset }
