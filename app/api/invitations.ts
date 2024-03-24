import endpoint from './endpoint.js'
const { action } = endpoint('invitations')

export default { byEmails: action('by-emails') }
