import app from '#app/app'
import { appLayout } from '#app/init_app_layout'
import { getQuerystringParameter } from '#app/lib/querystring_helpers'
import { reqres } from '#app/radio'

export async function initQuerystringActions () {
  const validEmail = getQuerystringParameter('validEmail')
  if (validEmail != null) {
    // we need to wait for app.user to be ready to get the validEmail value
    await reqres.request('wait:for', 'user')
    await reqres.request('wait:for', 'layout')
    await showValidEmailConfirmation(validEmail)
  }
}

async function showValidEmailConfirmation (validEmail) {
  const { default: ValidEmailConfirmation } = await import('#user/components/valid_email_confirmation.svelte')
  // user.attribute.validEmail has priority over the validEmail querystring
  // (even if hopefully, there is no reason for those to be different)
  if (app.user.loggedIn) validEmail = app.user.validEmail
  appLayout.showChildComponent('svelteModal', ValidEmailConfirmation, { props: { validEmail } })
}
