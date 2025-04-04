<script lang="ts">
  import { debounce } from 'underscore'
  import { API } from '#app/api/api'
  import { languages } from '#app/lib/active_languages'
  import Flash from '#app/lib/components/flash.svelte'
  import UpdatePassword from '#app/lib/components/update_password.svelte'
  import preq from '#app/lib/preq'
  import { onChange } from '#app/lib/svelte/svelte'
  import { domain } from '#app/lib/urls'
  import { askConfirmation } from '#general/lib/confirmation_modal'
  import { verifyEmailAvailability } from '#user/lib/email_tests'
  import { i18n, I18n } from '#user/lib/i18n'
  import { deleteMainUserAccount, mainUserStore, updateUser } from '#user/lib/main_user'
  import EmailValidation from './email_validation.svelte'

  // Narrow down $mainUserStore type
  if ($mainUserStore.loggedIn !== true) throw new Error('invalid logged in user')

  let flashLang, flashEmail, flashDiscoverability
  let fediversable = $mainUserStore.fediversable
  let poolActivities = $mainUserStore.poolActivities
  let userLang = $mainUserStore.language
  let emailValue = $mainUserStore.email

  const pickLanguage = async () => {
    flashLang = null
    if (userLang === $mainUserStore.language) return
    try {
      flashLang = { type: 'loading' }
      await updateUser('language', userLang)
      window.location.reload()
    } catch (err) {
      flashLang = err
    }
  }

  const onEmailChange = async () => {
    if (emailValue.trim() === '') return
    // email has been modified back to its original state
    // nothing to update and nothing to flash notify either
    if ($mainUserStore.email === emailValue) return
    try {
      const res = await verifyEmailAvailability(emailValue)
      if (!(res.status === 'available')) {
        flashEmail = {
          type: 'error',
          message: I18n('this email is not available. Please pick another one.'),
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
    if ($mainUserStore.email === emailValue) {
      return flashEmail = { type: 'info', message: 'this is already your email' }
    }
    try {
      flashEmail = { type: 'loading' }
      await updateUser('email', emailValue)
      flashEmail = {
        type: 'success',
        message: I18n('new_confirmation_email'),
      }
    } catch (err) {
      flashEmail = err
    }
  }

  const toggleFediversable = async () => {
    flashDiscoverability = null
    fediversable = !fediversable
    try {
      await updateUser('fediversable', fediversable)
    } catch (err) {
      fediversable = !fediversable
      flashDiscoverability = err
    }
  }

  const togglePoolActivities = async () => {
    flashDiscoverability = null
    poolActivities = !poolActivities
    try {
      await updateUser('poolActivities', poolActivities)
    } catch (err) {
      poolActivities = !poolActivities
      flashDiscoverability = err
    }
  }

  const sendDeletionFeedback = message => preq.post(API.feedback, {
    subject: '[account deletion]',
    message,
  })

  const deleteAccount = () => {
    const args = { username: $mainUserStore.username }
    askConfirmation({
      confirmationText: I18n('delete_account_confirmation', args),
      warningText: I18n('cant_undo_warning'),
      action: deleteMainUserAccount,
      formAction: sendDeletionFeedback,
      formLabel: "that would really help us if you could say a few words about why you're leaving:",
      formPlaceholder: "our love wasn't possible because",
      yes: 'delete your account',
      no: 'cancel',
    })
  }

  const lazyOnEmailChange = debounce(onEmailChange, 500)

  $: onChange(emailValue, lazyOnEmailChange)
  $: onChange(userLang, pickLanguage)
</script>

<form>
  <fieldset>
    <h2 class="first-title">{I18n('account')}</h2>
    <h3 class="label">{I18n('language')}</h3>
    <select name="language" aria-label="language picker" bind:value={userLang}>
      {#each Object.values(languages) as language}
        <option value={language.lang}>{language.lang} - {language.native}</option>
      {/each}
    </select>
    <Flash bind:state={flashLang} />

    <h3 class="title">{I18n('email')}</h3>
    <input type="email" placeholder={i18n('email')} bind:value={emailValue} />
    <Flash bind:state={flashEmail} />
    <p class="note">{I18n('email will not be publicly displayed.')}</p>
    <button class="light-blue-button" on:click={updateEmail}>{I18n('update email')}</button>

    {#if !$mainUserStore.validEmail}
      <EmailValidation />
    {/if}

    <h3>{I18n('password')}</h3>
    <UpdatePassword />
  </fieldset>

  <!-- TODO: Add checkbox for user.settings.contributions.anonymize -->

  <fieldset>
    <h2 class="title">{I18n('discoverability')}</h2>
    <p class="note">{@html I18n('fediversable_description', { username: $mainUserStore.stableUsername, host: domain })}</p>
    <label class="inline">
      <input
        type="checkbox"
        class="fediversable"
        bind:checked={fediversable}
        on:click={toggleFediversable} />
      {i18n('Fediverse integration')}
    </label>
    <p class="note">{i18n('To prevent sending too many messages, when several books are added at about the same time, only one summary message will be sent.')}</p>
    <label class="inline">
      <input
        type="checkbox"
        disabled={!fediversable}
        bind:checked={poolActivities}
        on:click={togglePoolActivities} />
      {i18n('Regroup recent publications in a single activity')}
    </label>
    <Flash bind:state={flashDiscoverability} />
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
    margin-block-start: 1em;
    margin-block-end: 1em;
  }
</style>
