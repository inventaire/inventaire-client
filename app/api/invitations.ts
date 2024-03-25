import endpoint from './endpoint.ts'

const { action } = endpoint('invitations')

export default { byEmails: action('by-emails') }
