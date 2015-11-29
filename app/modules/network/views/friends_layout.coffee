UsersList = require 'modules/users/views/users_list'
Users = require 'modules/users/collections/users'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
UsersSearch = require 'modules/network/plugins/users_search'
forms_ = require 'modules/general/lib/forms'

module.exports = Marionette.LayoutView.extend
  template: require './templates/friends_layout'
  id: 'friendsLayout'
  tagName: 'section'

  regions:
    friendsRequests: '#friendsRequests'
    usersAlreadyThereRegion: '#usersAlreadyThere'

  ui:
    friendsRequestsHeader: '#friendsRequestsHeader'
    invitations: '#invitations'
    addMessage: '#addMessage'
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
    'click #addMessage': 'toggleMessage'

  initialize: ->
    @initPlugins()
    @emailsInvited = []
    @usersAlreadyThere = new Backbone.Collection

  initPlugins: ->
    UsersSearch.call @

  onRender: ->
    behaviorsPlugin.startLoading.call @, '#usersList'
    app.request('waitForFriendsItems')
    .then @showFriendsLists.bind(@)
    .catch _.Error('showTabFriends')

    @usersAlreadyThereRegion.show new UsersList
      collection: @usersAlreadyThere
      stretch: true

  serializeData: ->
    rawEmails: @rawEmails
    message: @message
    emailsInvited: @emailsInvited

  showFriendsLists: ->
    @showFriendsRequests()
    @showUsersSearchBase(true)

  showFriendsRequests: ->
    { otherRequested } = app.users
    if otherRequested.length > 0
      @friendsRequests.show new UsersList
        collection: otherRequested
        emptyViewMessage: 'no pending requests'
        stretch: true
    else
      @ui.friendsRequestsHeader.hide()

  sendInvitations: ->
    # keeping rawEmails at hand to avoid emptying the textarea on re-render
    @rawEmails = @ui.invitations.val()
    @message = @ui.message.val()
    sendInvitationsByEmails @rawEmails, @message
    .catch invitationsError
    .then _.Log('invitation data')
    .then @_spreadUsers.bind(@)
    .then @_showResults.bind(@)
    .catch forms_.catchAlert.bind(null, @)
    .catch behaviorsPlugin.Fail.call @, 'invitations err'

  _spreadUsers: (data)->
    { users, emails } = data
    @addEmailsInvited emails
    for user in users
      @_addUser user

  addEmailsInvited: (emails)->
    @emailsInvited = _.uniq @emailsInvited.concat(emails)

  _addUser: (user)->
    userModel = app.users.public.add user
    # in cases the public was already there
    # the previous model will be kept and the email lost
    # and we want the email to be displayed here
    userModel.set 'email', user.email
    @usersAlreadyThere.add userModel
    # send a friend request only if no relation pre-existed
    switch userModel.get 'status'
      when 'public' then app.request 'request:send', userModel
      when 'otherRequested' then app.request 'request:accept', userModel, false

  _showResults: ->
    # rendering to display @emailsInvited in the each loop
    @render()
    if @usersAlreadyThere.length > 0
      @ui.usersAlreadyThere.slideDown()

    # waiting for everything to be well rendered
    setTimeout _.scrollTop.bind(null, @ui.invitations), 250

  toggleMessage: ->
    @ui.addMessage.slideUp()
    @ui.message.slideDown()

sendInvitationsByEmails = (rawEmails, message)->
  app.request 'invitations:by:emails', rawEmails, message

invitationsError = (err)->
  err.selector = '#invitations'
  throw err
