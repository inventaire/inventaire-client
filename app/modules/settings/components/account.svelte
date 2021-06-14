<script>
  import { i18n, I18n } from 'modules/user/lib/i18n'
  import preq from 'lib/preq'
  import _ from 'underscore'
  import Flash from 'lib/components/flash.svelte'
  import UpdatePassword from 'lib/components/update_password.svelte'
  import { languages as languagesObj } from 'lib/active_languages'
  import email_ from 'modules/user/lib/email_tests'

  export let user, requestedEmail
  let showFlashLang, hideFlashLang, showFlashEmail, hideFlashEmail, newEmail
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

  const onEmailChange = async () => {
    hideFlashEmail()
    // email has been modfied back to its original state
    // nothing to update and nothing to flash notify either
    if (currentEmail === newEmail) {
      return showFlashEmail({ priority: 'info', message: 'this is already your email' })
    }
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

  const debounceEmailChange = _.debounce(onEmailChange.bind(null, newEmail), 500)

  const updateEmail = async () => {
    hideFlashEmail()
    if (!newEmail || newEmail === currentEmail) {
      return showFlashEmail({ priority: 'info', message: 'this is already your email' })
    }
    try {
      const res = await preq.put(app.API.user, {
        attribute: 'email',
        value: newEmail
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
    let { message } = err
    if (message.startsWith('invalid email')) {
      message = I18n('this email is invalid.')
    }
    showFlashEmail({ priority: 'error', message })
  }

  const sendDeletionFeedback = message => preq.post(app.API.feedback, {
    subject: '[account deletion]',
    message
  }
  )

  const deleteAccount = () => {
    const args = { username: user.get('username') }
    app.execute('ask:confirmation', {
      confirmationText: i18n('delete_account_confirmation', args),
      warningText: i18n('cant_undo_warning'),
      action: user.deleteAccount.bind(user),
      formAction: sendDeletionFeedback,
      formLabel: "that would really help us if you could say a few words about why you're leaving:",
      formPlaceholder: "our love wasn't possible because",
      yes: 'delete your account',
      no: 'cancel'
    })
  }
</script>

<section class="first-section">
  <h2 class="first-title">{I18n('account')}</h2>
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
  <input placeholder="{i18n('email')}" value={currentEmail} on:keyup="{e => newEmail = e.target.value}" on:keyup="{e => debounceEmailChange(e.target.value)}"/>
  <Flash bind:show={showFlashEmail} bind:hide={hideFlashEmail}/>
  <p class="note">{I18n('email will not be publicly displayed.')}</p>
  <button class="light-blue-button" on:click="{updateEmail}">{I18n('update email')}</button>
</section>

<section>
  <h2>{I18n('password')}</h2>
  <UpdatePassword/>
</section>

<section class="danger-zone">
  <h2 class="title danger-zone-title">{I18n('danger zone')}</h2>
  <p class="note">{I18n('be careful, those actions might not be reversible')}</p>
  <button class="dangerous-button" on:click={deleteAccount}>{I18n('delete your account')}</button>
</section>

<style lang="scss">
  @import 'app/modules/settings/scss/section_settings_svelte';
  .danger-zone-title{
    color: $danger-color;
    font-weight: bold
  }
  input{
    appearance: none;
    border: 1px solid #AAA;
    margin-bottom: 0;
  }
  h3{
    margin-top: 1em;
    margin-bottom: 0.2em;
    font: sans-serif;
    font-size: 110%;
    font-weight: 600;
  }
</style>
