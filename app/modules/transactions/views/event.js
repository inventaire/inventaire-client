/* eslint-disable
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
// the Event view can have both Message or Action models
// the interest mixing those is to allow those views to be displayed
// on chronological order within the transaction timeline
export default Marionette.ItemView.extend({
  behaviors: {
    PreventDefault: {}
  },

  initialize () {
    this.isMessage = (this.model.get('message') != null)
    return this.setClassNames()
  },

  getTemplate () {
    if (this.isMessage) {
      return require('./templates/message')
    } else { return require('./templates/action') }
  },

  setClassNames () {
    if (this.isMessage) {
      return this.$el.addClass('message')
    } else { return this.$el.addClass('action') }
  },

  serializeData () {
    // both Message and Action model implement a serializeData method
    const attrs = this.model.serializeData()
    attrs.sameUser = this.sameUser()
    return attrs
  },

  modelEvents: {
    grab: 'render'
  },

  events: {
    'click .username': 'showOtherUser',
    'click .showUser': 'showUser'
  },

  // hide avatar on successsive messages from the same user
  sameUser () {
    if (!this.isMessage) { return }
    const index = this.model.collection.indexOf(this.model)
    if (index <= 0) { return }
    const prev = this.model.collection.models[index - 1]
    if (prev?.get('message') == null) { return }

    if (prev.get('user') === this.model.get('user')) {
      return true
    }
  },

  showUser (e) {
    if (!_.isOpenedOutside(e)) {
      return app.execute('show:inventory:user', this.model.user)
    }
  },

  showOtherUser (e) {
    if (!_.isOpenedOutside(e)) {
      return app.execute('show:inventory:user', this.model.transaction?.otherUser())
    }
  }
})
