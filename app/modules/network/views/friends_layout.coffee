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
    output: '#output'
    usersAlreadyThere: '.usersAlreadyThere'

  behaviors:
    Loading: {}
    ElasticTextarea: {}
    AlertBox: {}

  events:
    'click #sendInvitations': 'sendInvitations'

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
    getCleanAddresses @rawEmails
    .then @_getUsersData.bind(@)
    .then @_showResults.bind(@)
    .catch forms_.catchAlert.bind(null, @)

  _getUsersData: (emails)->
    findUserByEmail emails
    .then @_spreadUsers.bind(@, emails)

  _spreadUsers: (emails, users)->
    foundEmails = users.map _.property('email')
    newEmailsToInvite = _.difference(emails, foundEmails)
    @emailsInvited = @emailsInvited.concat newEmailsToInvite
    @sendEmailInvitations newEmailsToInvite
    users.forEach @_addUser.bind(@)

  _addUser: (user)->
    userModel = app.users.public.add user
    # in cases the public was already there
    # the previous model will be kept and the email lost
    # and we want the email to be displayed here
    userModel.set 'email', user.email
    @usersAlreadyThere.add userModel
    # send a friend request only if no relation pre-existed
    if userModel.get('status') is 'public'
      app.request 'request:send', userModel

  _showResults: ->
    # rendering to display @emailsInvited in the each loop
    @render()
    if @usersAlreadyThere.length > 0
      @ui.usersAlreadyThere.slideDown()

    _.scrollTop @ui.invitations

  sendEmailInvitations: (emailsToInvite)->
    app.request 'invitations:by:emails', emailsToInvite

findUserByEmail = (emails)->
  _.preq.get app.API.users.byEmails(emails)
  .then _.property('users')
  .then _.Log('users')

getCleanAddresses = (rawEmails)->
  _.preq.post app.API.services.parseEmails,
    emails: rawEmails
  .catch invitationsError

invitationsError = (err)->
  err.selector = '#invitations'
  throw err
