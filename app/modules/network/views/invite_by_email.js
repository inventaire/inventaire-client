import log_ from '#lib/loggers'
import UsersList from '#users/views/users_list'
import behaviorsPlugin from '#general/plugins/behaviors'
import forms_ from '#general/lib/forms'
import error_ from '#lib/error'
import inviteByEmailTemplate from './templates/invite_by_email.hbs'
import '../scss/invite_by_email.scss'
import AlertBox from '#behaviors/alert_box'
import ElasticTextarea from '#behaviors/elastic_textarea'
import Loading from '#behaviors/loading'
import SuccessCheck from '#behaviors/success_check'

export default Marionette.View.extend({
  template: inviteByEmailTemplate,
  id: 'inviteByEmail',

  regions: {
    usersAlreadyThereRegion: '#usersAlreadyThere'
  },

  ui: {
    invitations: '#invitations',
    message: '#message',
    output: '#output',
    usersAlreadyThere: '.usersAlreadyThere'
  },

  behaviors: {
    Loading,
    ElasticTextarea,
    AlertBox,
    SuccessCheck,
  },

  events: {
    'click #sendInvitations': 'sendInvitations'
  },

  initialize () {
    this.emailsInvited = []
    this.usersAlreadyThere = new Backbone.Collection()
    // If a group is passed, invitations are group invitations
    // else they are friend requests
    this.group = this.options.group
    this.groupId = this.group?.id
  },

  onRender () {
    if (this.group == null) app.execute('modal:open', 'medium')

    this.showChildView('usersAlreadyThereRegion', new UsersList({
      collection: this.usersAlreadyThere,
      stretch: false,
      showEmail: true,
      groupContext: (this.group != null),
      group: this.group
    }))
  },

  serializeData () {
    return {
      groupContext: (this.group != null),
      rawEmails: this.rawEmails,
      message: this.message,
      emailsInvited: this.emailsInvited,
      alreadyThereAction: this._getAlreadyThereAction()
    }
  },

  _getAlreadyThereAction () {
    if (this.group != null) {
      return 'invitation sent'
    } else {
      return 'friend request sent'
    }
  },

  sendInvitations () {
    // keeping rawEmails at hand to avoid emptying the textarea on re-render
    this.rawEmails = this.ui.invitations.val()
    this.message = this.ui.message.val()

    return app.request('invitations:by:emails', this.rawEmails, this.message, this.groupId)
    .catch(error_.Complete('#invitations'))
    .then(log_.Info('invitation data'))
    .then(this._spreadUsers.bind(this))
    .then(this._showResults.bind(this))
    .catch(forms_.catchAlert.bind(null, this))
    .catch(behaviorsPlugin.Fail.call(this, 'invitations err'))
  },

  _spreadUsers (data) {
    const { users, emails } = data
    this.addEmailsInvited(emails)
    return users.forEach(this._addUser.bind(this))
  },

  _addUser (user) {
    // TODO: get user model without adding it to global collections
    // that aren't used anywhere anymore
    const userModel = app.request('user:add', user)
    // in cases the public was already there
    // the previous model will be kept and the email lost
    // and we want the email to be displayed here
    userModel.set('email', user.email)
    this.usersAlreadyThere.add(userModel)

    if (this.group != null) {
      switch (this.group.userStatus(userModel)) {
      case 'none': return this.group.inviteUser(userModel)
      case 'requested': return this.group.acceptRequest(userModel)
      }
    } else {
      // send a friend request only if no relation pre-existed
      switch (userModel.get('status')) {
      case 'public': return app.request('request:send', userModel)
      case 'otherRequested': return app.request('request:accept', userModel, false)
      }
    }
  },

  addEmailsInvited (emails) {
    this.emailsInvited = _.uniq(this.emailsInvited.concat(emails))
  },

  _showResults () {
    // rendering to display @emailsInvited in the each loop
    this.render()
    if (this.emailsInvited.length > 0) {
      this.ui.output.attr('role', 'alert')
    }
    if (this.usersAlreadyThere.length > 0) {
      this.ui.usersAlreadyThere.attr('aria-live', 'polite')
      this.ui.usersAlreadyThere.slideDown()
    }
  }
})
