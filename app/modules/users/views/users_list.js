export default Marionette.CollectionView.extend({
  tagName: 'ul',
  className: 'usersList',
  childView: require('./user_li'),
  childViewOptions () {
    return {
      groupContext: this.options.groupContext,
      group: this.options.group,
      showEmail: this.options.showEmail,
      stretch: this.options.stretch
    }
  },
  emptyView: require('./no_user'),
  emptyViewOptions () {
    return {
      message: this.options.emptyViewMessage,
      link: this.options.emptyViewLink,
      showEmail: this.options.showEmail
    }
  },

  initialize () {
    const { filter, textFilter } = this.options
    if (filter != null) { this.filter = filter }

    if (textFilter) {
      return this.on('filter:text', this.setTextFilter.bind(this))
    }
  },

  setTextFilter (text) {
    this.filter = model => model.matches(text)
    return this.render()
  }
})
