import app from '#app/app'
import behaviorsPlugin from '#general/plugins/behaviors'
import log_ from '#lib/loggers'
import { I18n } from '#user/lib/i18n'

export default Marionette.Behavior.extend({
  events: {
    // general actions
    'click .cancel': 'cancel',
    'click .discard': 'discard',
    'click .accept': 'accept',
    'click .request': 'send',
    'click .unfriend': 'unfriend',
    // group actions
    'click .invite': 'invite',
    'click .acceptRequest': 'acceptRequest',
    'click .refuseRequest': 'refuseRequest',
    'click .makeAdmin': 'makeAdmin',
    'click .kick': 'kick',
  },

  cancel () { return app.request('request:cancel', this.view.model) },
  discard () { return app.request('request:discard', this.view.model) },
  accept () { return app.request('request:accept', this.view.model) },
  send () {
    if (app.request('require:loggedIn', this.view.model.get('pathname'))) {
      return app.request('request:send', this.view.model)
    }
  },

  unfriend () {
    this.confirmAction('unfriend', app.Request('unfriend', this.view.model))
  },

  invite () {
    if (this.view.group == null) return log_.error('inviteUser err: group is missing')

    return this.view.group.inviteUser(this.view.model)
    // @ts-expect-error
    .catch(behaviorsPlugin.Fail.call(this.view, 'invite user'))
  },

  acceptRequest () {
    if (this.view.group == null) return log_.error('acceptRequest err: group is missing')

    return this.view.group.acceptRequest(this.view.model)
    // @ts-expect-error
    .catch(behaviorsPlugin.Fail.call(this.view, 'accept user request'))
  },

  refuseRequest () {
    if (this.view.group == null) return log_.error('refuseRequest err: group is missing')

    return this.view.group.refuseRequest(this.view.model)
    // @ts-expect-error
    .catch(behaviorsPlugin.Fail.call(this.view, 'refuse user request'))
  },

  makeAdmin () {
    if (this.view.group == null) return log_.error('makeAdmin err: group is missing')
    const actionFn = this.view.group.makeAdmin.bind(this.view.group, this.view.model)
    const warningText = I18n('group_make_admin_warning')
    this.confirmAction('group_make_admin', actionFn, warningText)
  },

  kick () {
    if (this.view.group == null) return log_.error('kick err: group is missing')
    const actionFn = this.view.group.kick.bind(this.view.group, this.view.model)
    this.confirmAction('group_kick', actionFn)
  },

  confirmAction (actionLabel, action, warningText) {
    const username = this.view.model.get('username')
    const confirmationText = I18n(`${actionLabel}_confirmation`, { username })
    app.execute('ask:confirmation', { confirmationText, warningText, action })
  },
})
