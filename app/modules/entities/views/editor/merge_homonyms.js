import MergeSuggestion from './merge_homonym.js'
import NoResult from '#search/views/no_result'
import mergeHomonymsTemplate from './templates/merge_homonyms.hbs'

export default Marionette.CollectionView.extend({
  template: mergeHomonymsTemplate,
  className () {
    let className = 'outer-merge-homonyms'
    if (this.options.standalone) className += ' standalone'
    return className
  },
  childViewContainer: '.inner-merge-homonyms',
  childView: MergeSuggestion,
  initialize () {
    this.hasManySuggestions = this.collection.length > 1
  },

  childViewOptions () {
    return {
      toEntity: this.model,
      showCheckbox: this.hasManySuggestions
    }
  },

  emptyView: NoResult,
  serializeData () {
    const attrs = this.model.toJSON()
    attrs.standalone = this.options.standalone
    attrs.hasManySuggestions = this.hasManySuggestions
    return attrs
  },

  events: {
    'click .selectAll': 'selectAll',
    'click .unselectAll': 'unselectAll',
    'click .mergeSelectedSuggestions': 'mergeSelectedSuggestions'
  },

  selectAll () { return this.setAllSelected(true) },
  unselectAll () { return this.setAllSelected(false) },
  setAllSelected (bool) {
    return Array.from(this.$el.find('input[type="checkbox"]'))
    .forEach(el => { el.checked = bool })
  },

  mergeSelectedSuggestions () {
    const selectedViews = Object.values(this.children._views).filter(child => child.isSelected())

    const mergeSequentially = function () {
      const nextSelectedView = selectedViews.shift()
      if (nextSelectedView == null) return
      return nextSelectedView.merge()
      .then(mergeSequentially)
    }

    // Merge 3 at a time
    mergeSequentially()
    mergeSequentially()
    mergeSequentially()
  }
})
