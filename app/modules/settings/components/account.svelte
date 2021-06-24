<script>
  import { i18n, I18n } from 'modules/user/lib/i18n'
  import preq from 'lib/preq'
  import log_ from 'lib/loggers'
  import _ from 'underscore'
  import Flash from 'lib/components/flash.svelte'
  import UpdatePassword from 'lib/components/update_password.svelte'
  import { languages as languagesObj } from 'lib/active_languages'
  import email_ from 'modules/user/lib/email_tests'

  export let user, requestedEmail
  let flashLang, flashEmail
  const { lang } = user
  const userLanguage = languagesObj[lang]
  let userLang = userLanguage.lang
  const currentUserLang = userLang
  let emailValue = user.get('email')
  let currentEmail = emailValue

  const pickLanguage = async () => {
    flashLang = null
    if (userLang === currentUserLang) { return }
    try {
      flashLang = { type: 'loading' }
      const res = await preq.put(app.API.user, {
        attribute: 'language',
        value: userLang
      })
      if (res.ok) window.location.reload()
    } catch (err) {
      // Logs the error and report it
      log_.error(err)
      flashLang = {
        type: 'error',
        message: I18n('something went wrong, try again later')
      }
    }
  }

  const onEmailChange = async () => {
    // email has been modified back to its original state
    // nothing to update and nothing to flash notify either
    if (currentEmail === emailValue) { return }
    try {
      const res = await email_.verifyAvailability(emailValue)
      if (!(res.status === 'available')) {
        requestedEmail = emailValue
        flashEmail = {
          type: 'error',
          message: I18n('this email is not available. Please pick another one.')
        }
      } else {
        flashEmail = null
      }
    } catch (err) {
      flashEmail = err
    }
  }

  const updateEmail = async () => {
    flashEmail = null
    if (currentEmail === emailValue) {
      return flashEmail = { type: 'info', message: 'this is already your email' }
    }
    try {
      flashEmail = { type: 'loading' }
      await preq.put(app.API.user, {
        attribute: 'email',
        value: emailValue
      })
      flashEmail = {
        type: 'success',
        message: I18n('new_confirmation_email')
      }
      currentEmail = emailValue
    } catch (err) {
      flashEmail = err
    }
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

  $: (async () => await _.debounce(onEmailChange.bind(null, emailValue), 500)())()
  $: pickLanguage(userLang)
</script>

<section class="first-section">
  <h2 class="first-title">{I18n('account')}</h2>
  <h3 class="label">{I18n('language')}</h3>
  <select name="language" aria-label="language picker" bind:value="{userLang}">
    {#each Object.values(languagesObj) as language}
      <option value={language.lang}>{language.lang} - {language.native}</option>
    {/each}
  </select>
  <Flash bind:state={flashLang}/>
</section>

<section>
  <h2 class="title">{I18n('email')}</h2>
  <input placeholder="{i18n('email')}" bind:value={emailValue}/>
  <Flash bind:state={flashEmail}/>
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
  @import 'app/modules/settings/scss/common_settings';
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
  .note{
    color: $grey;
    font-size: 90%;
    margin-bottom: 1em;
  }
</style>
