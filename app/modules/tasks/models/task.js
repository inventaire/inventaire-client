import { i18n } from '#modules/user/lib/i18n'
import preq from '#lib/preq'
import mergeEntities from '#modules/entities/views/editor/lib/merge_entities'
import error_ from '#lib/error'

export default Backbone.Model.extend({
  initialize (attrs) {
    const type = this.get('type')
    if (type == null) { throw error_.new('invalid task', 500, attrs) }
    const entitiesType = this.get('entitiesType')
    if (entitiesType === 'human') { this.calculateGlobalScore() }
    return this.set('pathname', `/tasks/${this.id}`)
  },

  serializeData () {
    const data = _.extend(this.toJSON(), {
      suspect: this.suspect?.toJSON(),
      suggestion: this.suggestion?.toJSON(),
    })
    if (this.get('entitiesType') === 'human') {
      _.extend(data, {
        isHumansEntitiesType: true,
        sources: this.getSources(),
        sourcesCount: this.get('externalSourcesOccurrences').length
      })
    }
    return data
  },

  grabAuthor (name) {
    const uri = this.get(`${name}Uri`)
    return this.reqGrab('get:entity:model', uri, name)
    .then(model => {
      const resolvedUri = model.get('uri')
      if (resolvedUri !== uri) {
        const context = { task: this.id, oldUri: uri, newUri: resolvedUri }
        const err = error_.new(`${name} uri is obsolete`, 500, context)
        err.code = 'obsolete_task'
        throw err
      }

      if (model.get('type') === 'human') {
        return model.initAuthorWorks()
      }
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
    const title = `[${i18n(type)}] ${names}`
    return { title }
  },

  dismiss () {
    return preq.put(app.API.tasks.update, {
      id: this.id,
      attribute: 'state',
      value: 'dismissed'
    })
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
    this.set('globalScore', Math.trunc(score * 100) / 100)
  },

  getSources () {
    return this.get('externalSourcesOccurrences')
    .map(source => {
      const { url, uri, matchedTitles } = source
      const sourceTitle = 'Matched titles: ' + matchedTitles.join(', ')
      if (url) return { url, sourceTitle }
      if (uri) return { uri, sourceTitle }
    })
  }
})
