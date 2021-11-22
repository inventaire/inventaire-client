import { isNonEmptyString } from 'lib/boolean_tests'
import UsersList from 'modules/users/views/users_list'
import { startLoading } from 'modules/general/plugins/behaviors'
import usersSearchLayoutTemplate from './templates/users_search_layout.hbs'
import Loading from 'behaviors/loading'

export default Marionette.View.extend({
  id: 'usersSearchLayout',
  template: usersSearchLayoutTemplate,
  regions: {
    usersList: '#usersList'
  },

  behaviors: {
    Loading,
  },

  events: {
    'keyup #usersSearch': 'searchUserFromEvent'
  },

  initialize () {
    this.collection = app.users.filtered.resetFilters()
    this.initSearch()
  },

  serializeData () {
    return {
      usersSearch: {
        id: 'usersSearch',
        placeholder: 'search for users',
        value: this.lastQuery
      }
    }
  },

  onRender () {
    startLoading.call(this, '#usersList')
    this.lastQuery = ''
    this.showChildView('usersList', new UsersList({
      collection: this.collection,
      groupContext: this.options.groupContext,
      group: this.options.group,
      emptyViewMessage: this.options.emptyViewMessage,
      filter: this.options.filter
    }))

    // start with .noUser hidden
    // will eventually be re-shown by empty results later
    $('.noUser').hide()
  },

  initSearch () {
    const q = this.options.query?.q
    if (isNonEmptyString(q)) this.searchUser(q)
  },

  searchUserFromEvent (e) {
    const query = e.target.value
    this.searchUser(query)
  },

  searchUser (query) {
    this.lastQuery = query
    app.request('users:search', query)
  }
})
