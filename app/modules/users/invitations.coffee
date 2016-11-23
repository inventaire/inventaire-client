module.exports = (app, _)->

  app.reqres.setHandlers
    'invitations:by:emails': (emails, message)->
      _.preq.post app.API.invitations.byEmails,
        emails: emails
        message: message
