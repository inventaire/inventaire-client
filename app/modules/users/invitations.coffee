module.exports = (app, _)->

  invitationsByEmails = (emails)->
    _.preq.post app.API.invitations,
      action: 'by-emails'
      emails: emails

  return handlers =
    'invitations:by:emails': invitationsByEmails