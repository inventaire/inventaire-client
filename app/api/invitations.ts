import { getEndpointPathBuilders } from './endpoint.ts'

const { action } = getEndpointPathBuilders('invitations')

export default { byEmails: action('by-emails') }
