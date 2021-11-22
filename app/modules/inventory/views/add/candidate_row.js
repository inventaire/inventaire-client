import CandidateInfo from './candidate_info'
import candidateRowTemplate from './templates/candidate_row.hbs'

export default Marionette.View.extend({
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

  onRender () {
    this.listenTo(this.model, 'change', this.lazyRender)
    this.updateClassName()
    this.trigger('selection:changed')
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
    click: 'select'
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
  }
})

const showCandidateInfo = isbn => new Promise((resolve, reject) => app.layout.showChildView('modal', new CandidateInfo({ resolve, reject, isbn })))
