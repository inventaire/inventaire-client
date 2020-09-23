/* eslint-disable
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
const groupViewsCommons = {
  events: {
    'click .showGroup': 'showGroup',
    'click .showGroupBoard': 'showGroupBoard',
    'click .showGroupSettings': 'showGroupSettings',
    'click .showMembersMenu': 'showMembersMenu',
    'click .accept': 'acceptInvitation',
    'click .decline': 'declineInvitation',
    'click .joinRequest': 'joinRequest',
    'click .cancelRequest': 'cancelRequest'
  },

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

export default {
  GroupLayoutView: Marionette.LayoutView.extend(groupViewsCommons),
  GroupItemView: Marionette.ItemView.extend(groupViewsCommons)
}
