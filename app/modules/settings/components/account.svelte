<script>
  import { i18n, I18n } from 'modules/user/lib/i18n'
  import preq from 'lib/preq'
  import Flash from 'lib/components/flash.svelte'
  import { languages as languagesObj } from 'lib/active_languages'
  import email_ from 'modules/user/lib/email_tests'

  export let user, requestedEmail
  let showFlashLang, hideFlashLang, showFlashEmail, hideFlashEmail
  const { lang } = user
  let userLanguage = languagesObj[lang]
  const currentEmail = user.get('email')

  const pickLanguage = async selectedLang => {
    hideFlashLang()
    userLanguage = languagesObj[selectedLang]
    try {
      const res = await preq.put(app.API.user, {
        attribute: 'language',
        value: selectedLang
      })
      if (res.ok) window.location.reload()
    } catch {
      showFlashLang({
        priority: 'error',
        message: I18n('something went wrong, try again later')
      })
    }
  }

  const onEmailChange = async newEmail => {
    hideFlashEmail()
    // email has been modfied back to its original state
    // nothing to update and nothing to flash notify either
    if (currentEmail === newEmail) { return }
    try {
      const res = await email_.verifyAvailability(newEmail)
      if (res.status === 'available') {
        requestedEmail = newEmail
        showFlashEmail({
          priority: 'success',
          message: I18n('this email is valid and available.')
        })
      }
    } catch (err) {
      emailErrorHandling(err)
    }
  }

  const debouncedEmailChange = _.debounce(onEmailChange.bind(null, 'filter'), 500)

  const updateEmail = async requestedEmail => {
    hideFlashEmail()
    if (!requestedEmail || requestedEmail === currentEmail) {
      return showFlashEmail({ priority: 'info', message: 'this is already your email' })
    }
    try {
      const res = await preq.put(app.API.user, {
        attribute: 'email',
        value: requestedEmail
      })
      if (res.ok) {
        showFlashEmail({
          priority: 'success',
          message: I18n('new_confirmation_email')
        })
      }
    } catch (err) {
      emailErrorHandling(err)
    }
  }

  const emailErrorHandling = err => {
    let message
    if (err.message.startsWith('invalid email')) {
      message = I18n('this email is invalid.')
    } else {
      message = err.message
    }
    showFlashEmail({ priority: 'error', message })
  }
</script>

<section>
  <h2 class="title first-title">{I18n('account')}</h2>
  <h3 class="label">{I18n('language')}</h3>
  <select name="language" aria-label="language picker" value="{userLanguage.lang}" on:blur="{e => pickLanguage(e.target.value)}">
    {#each Object.values(languagesObj) as language}
      <option value={language.lang}>{language.lang} - {language.native}</option>
    {/each}
  </select>
  <Flash bind:show={showFlashLang} bind:hide={hideFlashLang}/>
</section>

<section>
  <h2 class="title">{I18n('email')}</h2>
  <input placeholder="{i18n('email')}" value={currentEmail} on:blur="{e => debouncedEmailChange(e.target.value)}"/>
  <Flash bind:show={showFlashEmail} bind:hide={hideFlashEmail}/>
  <p class="note">{I18n('email will not be publicly displayed.')}</p>
  <button class="light-blue-button" on:click="{updateEmail}">{I18n('update email')}</button>
</section>

<style lang="scss">
  @import 'app/modules/settings/scss/section_settings_svelte';
</style>
