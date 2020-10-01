const RelativeTask = Marionette.ItemView.extend({
  tagName: 'a',
  className () {
    let classes = 'relative-task'
    // if @model.get('hasEncyclopediaOccurence') then classes += ' good-candidate'
    if (this.model.get('globalScore') > 10) { classes += ' good-candidate' }
    return classes
  },

  attributes () {
    return {
      href: this.model.get('pathname'),
      'data-task-id': this.model.id
    }
  },

  template: require('./templates/relative_task'),
  initialize () {
    return this.model.grabSuggestion()
    .then(this.lazyRender.bind(this))
  },

  serializeData () { return this.model.serializeData() },

  events: {
    click: 'select'
  },

  select (e) {
    if (!_.isOpenedOutside(e)) {
      app.execute('show:task', this.model)
      return e.preventDefault()
    }
  }
})

export default Marionette.CollectionView.extend({
  className: 'inner-relative-tasks',
  childView: RelativeTask,
  initialize () {
    this.currentTaskModelId = this.options.currentTaskModel.id
  },

  filter (child) { return child.id !== this.currentTaskModelId }
})
