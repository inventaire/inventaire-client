import { API } from '#app/api/api'
import preq from '#app/lib/preq'

export function sendEmailInvitations ({ emails, message, group }) {
  return preq.post(API.invitations.byEmails, { emails, message, group })
}
