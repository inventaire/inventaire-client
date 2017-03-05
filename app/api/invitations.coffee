{ base, action } = require('./endpoint')('invitations')

module.exports =
  byEmails: action 'by-emails'
