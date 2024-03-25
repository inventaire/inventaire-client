import NoUser from './no_user.ts'
import UserLi from './user_li.ts'

export default Marionette.CollectionView.extend({
  tagName: 'ul',
  className: 'usersList',
  childView: UserLi,
  childViewOptions () {
    return {
      groupContext: this.options.groupContext,
      group: this.options.group,
      showEmail: this.options.showEmail,
      stretch: this.options.stretch,
    }
  },
  emptyView: NoUser,
  emptyViewOptions () {
    return {
      message: this.options.emptyViewMessage,
      link: this.options.emptyViewLink,
      showEmail: this.options.showEmail,
    }
  },

  initialize () {
    const { viewFilter, textFilter } = this.options
    if (viewFilter != null) this.viewFilter = viewFilter

    if (textFilter) {
      this.on('filter:text', this.setTextFilter.bind(this))
    }
  },

  setTextFilter (text) {
    this.viewFilter = view => view.model.matches(text)
    this.render()
  },
})
