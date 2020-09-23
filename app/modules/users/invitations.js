module.exports = (app, _)->
  app.reqres.setHandlers
    # If a groupId is passed, this is a group invitation
    # else it's a friend request
    'invitations:by:emails': (emails, message, group)->
      _.preq.post app.API.invitations.byEmails, { emails, message, group }
