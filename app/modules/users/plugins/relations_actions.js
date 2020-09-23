import behaviorsPlugin from 'modules/general/plugins/behaviors';
import { BasicPlugin } from 'lib/plugins';

const events = {
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
  'click .kick': 'kick'
};

const confirmAction = function(actionLabel, action, warningText){
  const confirmationText = _.I18n(`${actionLabel}_confirmation`,
    {username: this.model.get('username')});

  return app.execute('ask:confirmation', { confirmationText, warningText, action });
};

const confirmUnfriend = function() {
  return confirmAction.call(this, 'unfriend', app.Request('unfriend', this.model));
};

const handlers = {
  cancel() { return app.request('request:cancel', this.model); },
  discard() { return app.request('request:discard', this.model); },
  accept() { return app.request('request:accept', this.model); },
  send() {
    if (app.request('require:loggedIn', this.model.get('pathname'))) {
      return app.request('request:send', this.model);
    }
  },
  unfriend: confirmUnfriend,
  invite() {
    if (this.group == null) { return _.error('inviteUser err: group is missing'); }

    return this.group.inviteUser(this.model)
    .catch(behaviorsPlugin.Fail.call(this, 'invite user'));
  },

  acceptRequest() {
    if (this.group == null) { return _.error('acceptRequest err: group is missing'); }

    return this.group.acceptRequest(this.model)
    .catch(behaviorsPlugin.Fail.call(this, 'accept user request'));
  },

  refuseRequest() {
    if (this.group == null) { return _.error('refuseRequest err: group is missing'); }

    return this.group.refuseRequest(this.model)
    .catch(behaviorsPlugin.Fail.call(this, 'refuse user request'));
  },

  makeAdmin() {
    if (this.group == null) { return _.error('makeAdmin err: group is missing'); }
    const actionFn = this.group.makeAdmin.bind(this.group, this.model);
    const warningText = _.I18n('group_make_admin_warning');
    return confirmAction.call(this, 'group_make_admin', actionFn, warningText);
  },

  kick() {
    if (this.group == null) { return _.error('kick err: group is missing'); }
    const actionFn = this.group.kick.bind(this.group, this.model);
    return confirmAction.call(this, 'group_kick', actionFn);
  }
};

export default BasicPlugin(events, handlers);
