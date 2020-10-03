import { isOpenedOutside } from 'lib/utils'
import behaviorsPlugin from 'modules/general/plugins/behaviors'

export default {
  showGroup (e) {
    if (isOpenedOutside(e)) return
    app.execute('show:inventory:group', this.model)
  },

  showGroupBoard (e) {
    if (isOpenedOutside(e)) return
    app.execute('show:group:board', this.model)
  },

  showGroupSettings (e) {
    if (isOpenedOutside(e)) return
    app.execute('show:group:board', this.model, { openedSection: 'groupSettings' })
  },

  showMembersMenu (e) {
    if (isOpenedOutside(e)) return
    app.execute('show:group:board', this.model, { openedSection: 'groupInvite' })
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
