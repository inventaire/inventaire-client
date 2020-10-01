import isbn_ from 'lib/isbn'

export default Backbone.Model.extend({
  // Use the normalized ISBN as id to deduplicate entries
  idAttribute: 'isbn',
  initialize (attrs) {
    if (attrs.isbn != null) {
      if (attrs.rawIsbn == null) {
        this.set('rawIsbn', attrs.isbn)
      }
      if (attrs.normalizedIsbn == null) {
        this.set('normalizedIsbn', isbn_.normalizeIsbn(attrs.isbn))
      }
    }

    if (!this.get('uri') && (this.get('normalizedIsbn') != null)) {
      this.set('uri', `isbn:${this.get('normalizedIsbn')}`)
    }

    if (attrs.isInvalid) return

    this.setStatusData()

    this.on('change:title', this.updateInfoState.bind(this))
  },

  canBeSelected () { return !this.get('isInvalid') && !this.get('needInfo') },

  updateInfoState () {
    const needInfo = !_.isNonEmptyString(this.get('title'))
    return this.set('needInfo', needInfo)
  },

  setStatusData () {
    const existingEntityItemsCount = this.get('existingEntityItemsCount')
    if ((existingEntityItemsCount != null) && (existingEntityItemsCount > 0)) {
      const uri = this.get('uri')
      const username = app.user.get('username')
      return this.set('existingEntityItemsPathname', `/inventory/${username}/${uri}`)
    } else if ((this.get('title') == null)) {
      return this.set('needInfo', true)
    } else {
      return this.set('selected', true)
    }
  },

  createItem (params) {
    const { transaction, listing, shelves } = params
    return this.getEntityModel()
    .then(editionEntityModel => app.request('item:create', {
      entity: editionEntityModel.get('uri'),
      transaction,
      listing,
      shelves
    }))
  },

  getEntityModel () {
    // Always return a promise
    return Promise.try(() => {
      // Duck typing an entity model
      if (this.get('claims') != null) { return this }
      const entry = this.serializeResolverEntry()
      return app.request('entity:exists:or:create:from:seed', entry)
    })
  },

  serializeResolverEntry () {
    const data = this.toJSON()
    const { isbn, title, lang, authors: authorsNames, normalizedIsbn } = data
    const labelLang = lang || app.user.lang

    const edition = {
      isbn: isbn || normalizedIsbn,
      claims: {
        'wdt:P1476': [ title ]
      }
    }

    const work = { labels: {}, claims: {} }
    work.labels[labelLang] = title

    if (data.publicationDate != null) { edition.claims['wdt:P577'] = data.publicationDate }
    if (data.numberOfPages != null) { edition.claims['wdt:P1104'] = data.numberOfPages }
    if (data.goodReadsEditionId != null) { edition.claims['wdt:P2969'] = data.goodReadsEditionId }

    if (data.libraryThingWorkId != null) { work.claims['wdt:P1085'] = data.libraryThingWorkId }

    const authors = _.forceArray(authorsNames).map(name => {
      const labels = { [labelLang]: name }
      return { labels }
    })

    return { edition, works: [ work ], authors }
  }
})
