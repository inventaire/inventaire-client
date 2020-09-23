UsersList = require 'modules/users/views/users_list'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
screen_ = require 'lib/screen'

module.exports = Marionette.LayoutView.extend
  template: require './templates/invite_by_email'
  id: 'inviteByEmail'

  regions:
    usersAlreadyThereRegion: '#usersAlreadyThere'

  ui:
    invitations: '#invitations'
    message: '#message'
    output: '#output'
    usersAlreadyThere: '.usersAlreadyThere'

  behaviors:
    Loading: {}
    ElasticTextarea: {}
    AlertBox: {}
    SuccessCheck: {}

  events:
    'click #sendInvitations': 'sendInvitations'

  initialize: ->
    @emailsInvited = []
    @usersAlreadyThere = new Backbone.Collection
    # If a group is passed, invitations are group invitations
    # else they are friend requests
    { @group } = @options
    @groupId = @group?.id

  onShow: ->
    unless @group? then app.execute 'modal:open', 'medium'

  onRender: ->
    @usersAlreadyThereRegion.show new UsersList
      collection: @usersAlreadyThere
      stretch: false
      showEmail: true
      groupContext: @group?
      group: @group

  serializeData: ->
    groupContext: @group?
    rawEmails: @rawEmails
    message: @message
    emailsInvited: @emailsInvited
    alreadyThereAction: @_getAlreadyThereAction()

  _getAlreadyThereAction: ->
    if @group? then 'invitation sent'
    else 'friend request sent'

  sendInvitations: ->
    # keeping rawEmails at hand to avoid emptying the textarea on re-render
    @rawEmails = @ui.invitations.val()
    @message = @ui.message.val()

    app.request 'invitations:by:emails', @rawEmails, @message, @groupId
    .catch error_.Complete('#invitations')
    .then _.Log('invitation data')
    .then @_spreadUsers.bind(@)
    .then @_showResults.bind(@)
    .catch forms_.catchAlert.bind(null, @)
    .catch behaviorsPlugin.Fail.call(@, 'invitations err')

  _spreadUsers: (data)->
    { users, emails } = data
    @addEmailsInvited emails
    users.forEach @_addUser.bind(@)

  _addUser: (user)->
    # TODO: get user model without adding it to global collections
    # that aren't used anywhere anymore
    userModel = app.request 'user:add', user
    # in cases the public was already there
    # the previous model will be kept and the email lost
    # and we want the email to be displayed here
    userModel.set 'email', user.email
    @usersAlreadyThere.add userModel

    if @group?
      switch @group.userStatus userModel
        when 'none' then @group.inviteUser userModel
        when 'requested' then @group.acceptRequest userModel

    else
      # send a friend request only if no relation pre-existed
      switch userModel.get 'status'
        when 'public' then app.request 'request:send', userModel
        when 'otherRequested' then app.request 'request:accept', userModel, false

  addEmailsInvited: (emails)->
    @emailsInvited = _.uniq @emailsInvited.concat(emails)


  _showResults: ->
    # rendering to display @emailsInvited in the each loop
    @render()
    if @usersAlreadyThere.length > 0
      @ui.usersAlreadyThere.slideDown()
