import { I18n } from '#user/lib/i18n'
import EntityEdit from './entity_edit.js'
import entityDraftModel from '../../lib/entity_draft_model'

export default EntityEdit.extend({
  initialize () {
    EntityEdit.prototype.initialize.call(this);
    ({ next: this.next, previous: this.previous, relation: this.relation, fromIsbn: this.fromIsbn } = this.options)
  },

  serializeData () {
    return _.extend(EntityEdit.prototype.serializeData.call(this), this.multiEditData())
  },

  multiEditData () {
    const data = {}
    if (this.fromIsbn != null) {
      data.header = I18n('can you tell us more about this work and this particular edition?')
      data.headerContext = 'ISBN: ' + this.fromIsbn
    }
    if (this.next != null) {
      data.next = this.next
      data.progress = { current: 1, total: 2 }
    }
    if (this.previous != null) {
      data.previous = this.previous
      data.progress = { current: 2, total: 2 }
    }
    return data
  },

  events: _.extend({}, EntityEdit.prototype.events, {
    'click #next': 'showNextMultiEditPage',
    'click #previous': 'showPreviousMultiEditPage'
  }),

  showNextMultiEditPage () {
    const { next } = this.options
    const { labelTransfer } = next
    const draftModel = serializeDraftModel(this.model)
    next.previous = draftModel
    if (labelTransfer != null) next.claims[labelTransfer] = [ draftModel.label ]
    this.navigateMultiEdit(next)
  },

  showPreviousMultiEditPage () {
    const { relation } = this.options
    this.previous.next = serializeDraftModel(this.model, relation)
    this.navigateMultiEdit(this.previous)
  },

  navigateMultiEdit (data) {
    data.fromIsbn = this.options.fromIsbn
    app.execute('show:entity:create', data)
  },

  // Never display a cancel button when creating in mutliEdit mode as it means
  // an entity wasn't found and redirected here, which means hitting a
  // redirection loop
  canCancel () { return false },

  beforeCreate () { return this.createPreviousAndUpdateCurrentModel() },

  createPreviousAndUpdateCurrentModel () {
    return this.createPrevious()
    .then(previousEntityModel => {
      const claims = this.model.get('claims')
      const relationUri = previousEntityModel.get('uri')
      // Replace the draft data object by the uri
      claims[this.relation] = [ relationUri ]
      this.model.set('claims', claims)
      // Invalidate the cache so that next time it is requested
      // it will find the entity about to be created
      // Ex: in case of a work and an edition being created, invalidating
      // the cache of the work will force it to re-query its edition,
      // hopefully once the edition about to be created is made available
      // by the database
      app.execute('invalidate:entities:graph', relationUri)
    })
  },

  createPrevious () {
    const draftModel = entityDraftModel.create(this.previous)
    return draftModel.create()
  }
})

// Matching entityDraftModel.create interface to allow to re-create the draft model
// from the URL
const serializeDraftModel = function (model, relation) {
  let { labels, claims } = model.pick('labels', 'claims')
  const label = _.values(labels)[0]
  const { type } = model
  // Omit the relation property to avoid conflict/cyclic references
  if (relation != null) claims = _.omit(claims, relation)
  return { type, claims, label, relation }
}
