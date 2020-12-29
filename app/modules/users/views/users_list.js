import UserLi from './user_li'
import NoUser from './no_user'

export default Marionette.CollectionView.extend({
  tagName: 'ul',
  className: 'usersList',
  childView: UserLi,
  childViewOptions () {
    return {
      groupContext: this.options.groupContext,
      group: this.options.group,
      showEmail: this.options.showEmail,
      stretch: this.options.stretch
    }
  },
  emptyView: NoUser,
  emptyViewOptions () {
    return {
      message: this.options.emptyViewMessage,
      link: this.options.emptyViewLink,
      showEmail: this.options.showEmail
    }
  },

  initialize () {
    const { filter, textFilter } = this.options
    if (filter != null) this.filter = filter

    if (textFilter) {
      this.on('filter:text', this.setTextFilter.bind(this))
    }
  },

  setTextFilter (text) {
    this.filter = model => model.matches(text)
    this.render()
  }
})
