module.exports = (app, _)->

  invitationsByEmails = (emails, message)->
    _.preq.post app.API.invitations,
      action: 'by-emails'
      emails: emails
      message: message

  return handlers =
    'invitations:by:emails': invitationsByEmails