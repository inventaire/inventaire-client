const { action } = require('./endpoint')('invitations')

export default { byEmails: action('by-emails') }
