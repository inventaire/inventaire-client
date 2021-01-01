import CandidateInfo from './candidate_info'
import candidateRowTemplate from './templates/candidate_row.hbs'
import Entity from '../../../entities/models/entity'

export default Marionette.ItemView.extend({
  tagName: 'li',
  template: candidateRowTemplate,
  className () {
    let base = 'candidate-row'
    if (this.model.get('isInvalid')) {
      base += ' invalid'
    } else if (this.model.get('needInfo')) {
      base += ' need-info'
    } else {
      base += ' can-be-selected'
      if (this.model.get('selected')) base += ' selected'
    }
    return base
  },

  initialize () {
    if (this.isSelectable()) { this.editionModel = new Entity(this.model.attributes) }
  },

  onShow () {
    this.listenTo(this.model, 'change', this.lazyRender)
  },

  async onRender () {
    this.updateClassName()
    this.trigger('selection:changed')
    if (this.editionModel) {
      const authors = await this.editionModel.waitForWorks.then(getAndFormatAuthors)
      this.model.set('authors', authors)
    }
  },

  ui: {
    checkbox: 'input'
  },

  events: {
    'change input': 'updateSelected',
    'click .addInfo': 'addInfo',
    'click .remove': 'remov',
    // General click event: use stopPropagation to avoid triggering it
    // from other click event handlers
    'click input': 'select'
  },

  updateSelected (e) {
    const { checked } = e.currentTarget
    this.model.set('selected', checked)
    e.stopPropagation()
  },

  select (e) {
    const { tagName } = e.target
    // Do not interpret click on anchors such as .existing-entity-items links as a select
    // Do not interpret click on spans as a select as that prevents selecting text
    if ((tagName === 'A') || (tagName === 'SPAN')) return

    if (this.model.canBeSelected()) {
      const currentSelectedMode = this.model.get('selected')
      // Let the model events listener update the checkbox
      return this.model.set('selected', !currentSelectedMode)
    } else if (this.model.get('needInfo')) { return this.addInfo() }
  },

  addInfo (e) {
    showCandidateInfo(this.model.get('isbn'))
    .then(data => {
      const { title, authors } = data
      return this.model.set({ title, authors, selected: true })
    })
    .catch(err => {
      if (err.message !== 'modal closed') throw err
    })

    e?.stopPropagation()
  },

  // Avoid overriding Backbone.View::remove
  remov (e) {
    this.model.collection.remove(this.model)
    e.stopPropagation()
  },

  isSelectable () {
    return !(this.model.get('isInvalid') || this.model.get('needInfo'))
  }
})

const showCandidateInfo = isbn => new Promise((resolve, reject) => app.layout.modal.show(new CandidateInfo({ resolve, reject, isbn })))

const getAndFormatAuthors = async works => {
  const worksWithAuthorsModels = await Promise.all(works.map(work => work.getExtendedAuthorsModels()))
  const authorsModelByWork = worksWithAuthorsModels.map(_.property('wdt:P50'))
  const authorsModels = _.uniq(_.flatten(authorsModelByWork))
  return authorsModels.map(authorModel => {
    const name = authorModel.get('label')
    const uri = authorModel.get('uri')
    return { name, uri }
  })
}
