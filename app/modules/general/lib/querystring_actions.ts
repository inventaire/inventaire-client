import { appLayout } from '#app/init_app_layout'
import { getQuerystringParameter } from '#app/lib/querystring_helpers'
import { mainUser } from '#user/lib/main_user'

export async function initQuerystringActions () {
  const validEmail = getQuerystringParameter('validEmail')
  if (validEmail != null) {
    // we need to wait for mainUser to be ready to get the validEmail value
    await showValidEmailConfirmation(validEmail)
  }
}

async function showValidEmailConfirmation (validEmail) {
  const { default: ValidEmailConfirmation } = await import('#user/components/valid_email_confirmation.svelte')
  // user.attribute.validEmail has priority over the validEmail querystring
  // (even if hopefully, there is no reason for those to be different)
  if (mainUser) validEmail = mainUser.validEmail
  appLayout.showChildComponent('svelteModal', ValidEmailConfirmation, { props: { validEmail } })
}
