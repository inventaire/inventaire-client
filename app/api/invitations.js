import endpoint from './endpoint'
const { action } = endpoint('invitations')

export default { byEmails: action('by-emails') }
