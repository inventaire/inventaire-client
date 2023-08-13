<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import preq from '#lib/preq'
  import _ from 'underscore'
  import Flash from '#lib/components/flash.svelte'
  import EmailValidation from './email_validation.svelte'
  import UpdatePassword from '#lib/components/update_password.svelte'
  import languagesData from '#assets/js/languages_data'
  import email_ from '#user/lib/email_tests'
  import { user } from '#user/user_store'
  import { domain } from '#lib/urls'

  let flashLang, flashEmail, flashFediversable
  let fediversable = $user.fediversable
  let userLang = $user.language
  let emailValue = $user.email

  const pickLanguage = async () => {
    flashLang = null
    if (userLang === $user.language) return
    try {
      flashLang = { type: 'loading' }
      await app.request('user:update', {
        attribute: 'language',
        value: userLang
      })
      window.location.reload()
    } catch (err) {
      flashLang = err
    }
  }

  const onEmailChange = async () => {
    if (emailValue.trim() === '') return
    // email has been modified back to its original state
    // nothing to update and nothing to flash notify either
    if ($user.email === emailValue) return
    try {
      const res = await email_.verifyAvailability(emailValue)
      if (!(res.status === 'available')) {
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
    if ($user.email === emailValue) {
      return flashEmail = { type: 'info', message: 'this is already your email' }
    }
    try {
      flashEmail = { type: 'loading' }
      await app.request('user:update', {
        attribute: 'email',
        value: emailValue
      })
      flashEmail = {
        type: 'success',
        message: I18n('new_confirmation_email')
      }
    } catch (err) {
      flashEmail = err
    }
  }

  const toggleFediversable = async () => {
    flashFediversable = null
    fediversable = !fediversable
    try {
      await app.request('user:update', {
        attribute: 'fediversable',
        value: fediversable
      })
    } catch (err) {
      fediversable = !fediversable
      flashFediversable = err
    }
  }

  const sendDeletionFeedback = message => preq.post(app.API.feedback, {
    subject: '[account deletion]',
    message
  })

  const deleteAccount = () => {
    const args = { username: $user.username }
    app.execute('ask:confirmation', {
      confirmationText: i18n('delete_account_confirmation', args),
      warningText: i18n('cant_undo_warning'),
      action: app.user.deleteAccount.bind(app.user),
      formAction: sendDeletionFeedback,
      formLabel: "that would really help us if you could say a few words about why you're leaving:",
      formPlaceholder: "our love wasn't possible because",
      yes: 'delete your account',
      no: 'cancel'
    })
  }

  const lazyOnEmailChange = _.debounce(onEmailChange, 500)

  $: lazyOnEmailChange(emailValue)
  $: pickLanguage(userLang)
</script>

<form>
  <fieldset>
    <h2 class="first-title">{I18n('account')}</h2>
    <h3 class="label">{I18n('language')}</h3>
    <select name="language" aria-label="language picker" bind:value={userLang}>
      {#each Object.values(languagesData) as language}
        <option value={language.lang}>{language.lang} - {language.native}</option>
      {/each}
    </select>
    <Flash bind:state={flashLang} />

    <h3 class="title">{I18n('email')}</h3>
    <input placeholder={i18n('email')} bind:value={emailValue} />
    <Flash bind:state={flashEmail} />
    <p class="note">{I18n('email will not be publicly displayed.')}</p>
    <button class="light-blue-button" on:click={updateEmail}>{I18n('update email')}</button>

    {#if !$user.validEmail}
      <h3 class="label">{I18n('unverified email')}</h3>
      <EmailValidation />
    {/if}

    <h3>{I18n('password')}</h3>
    <UpdatePassword />
  </fieldset>

  <!-- TODO: Add checkbox for user.settings.contributions.anonymize -->

  <fieldset>
    <h2 class="title">{I18n('discoverability')}</h2>
    <p class="note">{@html I18n('fediversable_description', { username: $user.stableUsername, host: domain })}</p>
    <label class="inline">
      <input
        type="checkbox"
        class="fediversable"
        bind:checked={fediversable}
        on:click={toggleFediversable} />
      {i18n('Fediverse integration')}
    </label>
    <Flash bind:state={flashFediversable} />
  </fieldset>

  <fieldset class="danger-zone">
    <h2 class="title danger-zone-title">{I18n('danger zone')}</h2>
    <p class="note">{I18n('be careful, those actions might not be reversible')}</p>
    <button class="dangerous-button" on:click={deleteAccount}>{I18n('delete your account')}</button>
  </fieldset>
</form>

<style lang="scss">
  @import "#settings/scss/common_settings";
  .danger-zone-title{
    color: $darker-danger-color;
    font-weight: bold;
  }
  input{
    border: 1px solid #aaa;
    margin-block-end: 0;
  }
  input[type="checkbox"]{
    margin-inline-end: 0.5em;
  }
  label{
    font-size: 1rem;
  }
  .inline{
    display: flex;
    align-items: center;
  }
  h3{
    @include settings-h3;
  }
  .note{
    color: $grey;
    font-size: 0.9rem;
    margin-block-end: 1em;
  }
</style>
