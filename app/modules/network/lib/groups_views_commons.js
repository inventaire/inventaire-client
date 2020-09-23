export default {
  showGroup (e) {
    if (_.isOpenedOutside(e)) {

    } else { return app.execute('show:inventory:group', this.model) }
  },

  showGroupBoard (e) {
    if (_.isOpenedOutside(e)) {

    } else { return app.execute('show:group:board', this.model) }
  },

  showGroupSettings (e) {
    if (_.isOpenedOutside(e)) {

    } else { return app.execute('show:group:board', this.model, { openedSection: 'groupSettings' }) }
  },

  showMembersMenu (e) {
    if (_.isOpenedOutside(e)) {

    } else { return app.execute('show:group:board', this.model, { openedSection: 'groupInvite' }) }
  },

  acceptInvitation () { return this.model.acceptInvitation() },
  declineInvitation () { return this.model.declineInvitation() },
  joinRequest () {
    if (app.request('require:loggedIn', this.model.get('pathname'))) {
      return this.model.requestToJoin()
      .catch(behaviorsPlugin.Fail.call(this, 'joinRequest'))
    }
  },

  cancelRequest () {
    return this.model.cancelRequest()
    .catch(behaviorsPlugin.Fail.call(this, 'cancelRequest'))
  }
}
