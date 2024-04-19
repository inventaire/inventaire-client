import app from '#app/app'
import { get as getQuerystringParameter } from '#app/lib/querystring_helpers'

export async function initQuerystringActions () {
  const validEmail = getQuerystringParameter('validEmail')
  if (validEmail != null) {
    // we need to wait for app.user to be ready to get the validEmail value
    await app.request('wait:for', 'user')
    await app.request('wait:for', 'layout')
    await showValidEmailConfirmation(validEmail)
  }
}

async function showValidEmailConfirmation (validEmail) {
  const { default: ValidEmailConfirmation } = await import('#user/components/valid_email_confirmation.svelte')
  // user.attribute.validEmail has priority over the validEmail querystring
  // (even if hopefully, there is no reason for those to be different)
  if (app.user.loggedIn) validEmail = app.user.get('validEmail')
  app.layout.showChildComponent('svelteModal', ValidEmailConfirmation, { props: { validEmail } })
}
