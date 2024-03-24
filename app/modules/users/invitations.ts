import preq from '#lib/preq'

export function sendEmailInvitations ({ emails, message, group }) {
  return preq.post(app.API.invitations.byEmails, { emails, message, group })
}
