{ authentified } = require('./endpoint')('invitations')

module.exports =
  byEmails: "#{authentified}?action=by-emails"
