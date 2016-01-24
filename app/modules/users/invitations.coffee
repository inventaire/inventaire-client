module.exports = (app, _)->

  invitationsByEmails = (emails, message)->
    tracker =
    _.preq.post app.API.invitations,
      action: 'by-emails'
      emails: emails
      message: message
    .then (data)->
      # /!\ might count several times dupplicated emails
      # as data.emails is returned before filtering those out
      app.execute 'track:invitation', 'email', data.emails.length
      return data

  app.reqres.setHandlers
    'invitations:by:emails': invitationsByEmails

  return
