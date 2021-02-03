import { isOpenedOutside } from 'lib/utils'
import behaviorsPlugin from 'modules/general/plugins/behaviors'
import { i18n } from 'modules/user/lib/i18n'

const groupViewsCommons = {
  events: {
    'click .showGroup': 'showGroup',
    'click .showGroupBoard': 'showGroupBoard',
    'click .showGroupSettings': 'showGroupSettings',
    'click .showMembersMenu': 'showMembersMenu',
    'click .accept': 'acceptInvitation',
    'click .decline': 'declineInvitation',
    'click .joinRequest': 'joinRequest',
    'click .joinGroup': 'joinGroup',
    'click .cancelRequest': 'cancelRequest'
  },

  showGroup (e) {
    if (isOpenedOutside(e)) return
    app.execute('show:inventory:group', this.model)
    e.stopPropagation()
  },

  showGroupBoard (e) {
    if (isOpenedOutside(e)) return
    app.execute('show:group:board', this.model)
    e.stopPropagation()
  },

  showGroupSettings (e) {
    if (isOpenedOutside(e)) return
    app.execute('show:group:board', this.model, { openedSection: 'groupSettings' })
    e.stopPropagation()
  },

  showMembersMenu (e) {
    if (isOpenedOutside(e)) return
    app.execute('show:group:board', this.model, { openedSection: 'groupInvite' })
    e.stopPropagation()
  },

  acceptInvitation () { return this.model.acceptInvitation() },
  declineInvitation () { return this.model.declineInvitation() },
  joinGroup () {
    if (app.request('require:loggedIn', this.model.get('pathname'))) {
      return app.execute('ask:confirmation', {
        confirmationText: i18n('join_open_group_confirmation', { name: this.model.get('name') }),
        warningText: i18n('join_open_group_warning'),
        action: this.joinGroupAction.bind(this)
      })
    }
  },
  joinRequest () {
    if (app.request('require:loggedIn', this.model.get('pathname'))) {
      return this.model.requestToJoin()
    .catch(behaviorsPlugin.Fail.call(this, 'joinRequest'))
    }
  },
  joinGroupAction () {
    return this.model.joinGroup()
    .catch(behaviorsPlugin.Fail.call(this, 'joinGroup'))
  },

  cancelRequest () {
    return this.model.cancelRequest()
    .catch(behaviorsPlugin.Fail.call(this, 'cancelRequest'))
  }
}

export const GroupLayoutView = Marionette.LayoutView.extend(groupViewsCommons)
export const GroupItemView = Marionette.ItemView.extend(groupViewsCommons)
