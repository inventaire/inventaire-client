import preq from 'lib/preq'
import forms_ from 'modules/general/lib/forms'
import error_ from 'lib/error'
import behaviorsPlugin from 'modules/general/plugins/behaviors'
import History from './history'
import mergeEntities from './lib/merge_entities'
import { normalizeUri } from 'modules/entities/lib/entities'

export default Marionette.LayoutView.extend({
  template: require('./templates/admin_section'),

  behaviors: {
    PreventDefault: {},
    AlertBox: {},
    Loading: {}
  },

  regions: {
    history: '#history',
    mergeSuggestion: '#merge-suggestion'
  },

  ui: {
    mergeWithInput: '#mergeWithField',
    historyTogglers: '#historyToggler i.fa'
  },

  initialize () {
    this._historyShown = false
    return this.showHistorySection = app.user.hasAdminAccess
  },

  serializeData () {
    return {
      canBeMerged: this.canBeMerged(),
      mergeWith: mergeWithData(),
      isAnEdition: this.model.type === 'edition',
      isWikidataEntity: this.model.get('isWikidataEntity'),
      isInvEntity: this.model.get('isInvEntity'),
      wikidataEntityHistoryHref: this.model.get('wikidata.history'),
      showHistorySection: this.showHistorySection
    }
  },

  events: {
    'click #mergeWithButton': 'merge',
    'click .deleteEntity': 'deleteEntity',
    'click #showMergeSuggestions': 'showMergeSuggestions',
    'click #historyToggler': 'toggleHistory'
  },

  canBeMerged () {
    if (this.model.type !== 'edition') { return true }
    // Editions that have no ISBN can be merged
    if ((this.model.get('claims.wdt:P212') == null)) { return true }
    return false
  },

  showMergeSuggestions () {
    return app.execute('show:merge:suggestions', { region: this.mergeSuggestion, model: this.model })
  },

  merge (e) {
    behaviorsPlugin.startLoading.call(this, '#mergeWithButton')

    const fromUri = this.model.get('uri')
    const toUri = normalizeUri(this.ui.mergeWithInput.val().trim())

    return mergeEntities(fromUri, toUri)
    .then(app.Execute('show:entity:from:model'))
    .catch(error_.Complete('#mergeWithField', false))
    .catch(forms_.catchAlert.bind(null, this))
  },

  showHistory () {
    return this.model.fetchHistory()
    .then(() => this.history.show(new History({ model: this.model })))
  },

  toggleHistory () {
    if (!this.history.hasView()) { this.showHistory() }
    this.history.$el.toggleClass('hidden')
    return this.ui.historyTogglers.toggle()
  },

  deleteEntity () {
    return app.execute('ask:confirmation', {
      confirmationText: _.I18n('delete_entity_confirmation', { label: this.model.get('label') }),
      action: this._deleteEntity.bind(this)
    })
  },

  _deleteEntity () {
    const uri = this.model.get('invUri')
    return preq.post(app.API.entities.delete, { uris: [ uri ] })
    .then(() => app.execute('show:entity:edit', uri))
    .catch(displayDeteEntityErrorContext.bind(this))
  }
})

const mergeWithData = () => ({
  nameBase: 'mergeWith',

  field: {
    placeholder: 'ex: wd:Q237087',
    dotdotdot: ''
  },

  button: {
    text: _.I18n('merge'),
    classes: 'light-blue bold postfix'
  }
})

const displayDeteEntityErrorContext = function (err) {
  const { context } = err.responseJSON
  if (context) {
    console.log('context', context)
    const claims = (context.claim != null) ? [ context.claim ] : context.claims
    if (claims != null) {
      const contextText = claims.map(buildClaimLink).join('')
      err.richMessage = `${err.message}: <ul>${contextText}</ul>`
    }
  }

  error_.complete(err, '.delete-alert', false)
  // Display the alertbox on the admin_section view
  forms_.catchAlert(this, err)

  // Rethrow the error to let the confirmation modal display a fail status
  throw err
}

const buildClaimLink = claim => `<li><a href='/entity/${claim.entity}/edit' class='showEntityEdit'>${claim.property} - ${claim.entity}</a></li>`
