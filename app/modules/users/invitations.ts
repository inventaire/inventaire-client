import { API } from '#app/api/api'
import { treq } from '#app/lib/preq'
import type { PostInvitationsByEmailsResponse } from '#server/controllers/invitations/by_emails'
import type { GroupId } from '#server/types/group'

export function sendEmailInvitations ({ emails, message, group }: { emails: string[], message: string, group: GroupId }) {
  return treq.post<PostInvitationsByEmailsResponse>(API.invitations.byEmails, { emails, message, group })
}
