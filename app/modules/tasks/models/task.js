import mergeEntities from 'modules/entities/views/editor/lib/merge_entities'
import error_ from 'lib/error'

export default Backbone.Model.extend({
  initialize (attrs) {
    if (this.get('type') == null) { throw error_.new('invalid task', 500, attrs) }

    this.calculateGlobalScore()

    return this.set('pathname', `/tasks/${this.id}`)
  },

  serializeData () {
    return _.extend(this.toJSON(), {
      suspect: this.suspect?.toJSON(),
      suggestion: this.suggestion?.toJSON(),
      sources: this.getSources(),
      sourcesCount: this.get('externalSourcesOccurrences').length
    }
    )
  },

  grabAuthor (name) {
    const uri = this.get(`${name}Uri`)
    return this.reqGrab('get:entity:model', uri, name)
    .then(model => {
      const resolvedUri = model.get('uri')
      if (resolvedUri !== uri) {
        const context = { task: this.id, oldUri: uri, newUri: resolvedUri }
        throw error_.new(`${name} uri is obsolete`, 500, context)
      }

      return model.initAuthorWorks()
    })
  },

  grabSuspect () { return this.grabAuthor('suspect') },

  grabSuggestion () { return this.grabAuthor('suggestion') },

  getOtherSuggestions () {
    return this.suspect.fetchMergeSuggestions()
  },

  updateMetadata () {
    const type = this.get('type') || 'task'
    const names = this.suspect?.get('label') + ' / ' + this.suggestion?.get('label')
    const title = `[${_.i18n(type)}] ${names}`
    return { title }
  },

  dismiss () {
    return _.preq.put(app.API.tasks.update, {
      id: this.id,
      attribute: 'state',
      value: 'dismissed'
    }
    )
  },

  merge () {
    return mergeEntities(this.get('suspectUri'), this.get('suggestionUri'))
  },

  calculateGlobalScore () {
    let score = 0
    const externalSourcesOccurrencesCount = this.get('externalSourcesOccurrences').length
    score += 80 * externalSourcesOccurrencesCount
    score += this.get('lexicalScore')
    score += this.get('relationScore') * 10
    return this.set('globalScore', Math.trunc(score * 100) / 100)
  },

  getSources () {
    return this.get('externalSourcesOccurrences')
    .map(source => {
      const { url, uri, matchedTitles } = source
      const sourceTitle = 'Matched titles: ' + matchedTitles.join(', ')
      if (url) { return { url, sourceTitle } }
      if (uri) { return { uri, sourceTitle } }
    })
  }
})
