<script>
  import { i18n, I18n } from 'modules/user/lib/i18n'
  import preq from 'lib/preq'
  import Flash from 'lib/components/flash.svelte'
  export let user
  let showFlashBio, showFlashUsername, hideFlashUsername, hideFlashBio
  let currentUsername = user.attributes.label
  let requestedUsername
  let bio = user.attributes.bio || ''

  const updateUsername = async () => {
    if (!requestedUsername || requestedUsername === currentUsername) {
      return showFlashUsername({ priority: 'info', message: 'this is already your username' })
    }

    try {
      await app.execute('ask:confirmation', {
        confirmationText: i18n('username_change_confirmation', { requestedUsername, currentUsername }),
        // no need to show the warning if it's just a case change
        warningText: !doesUsernameCaseChange() ? i18n('username_change_warning') : undefined,
        action: updateUserReq('username', requestedUsername)
      })
      currentUsername = requestedUsername
    } catch {
      showUsernameError('something went wrong, try again later')
    }
  }

  const doesUsernameCaseChange = () => requestedUsername.toLowerCase() === currentUsername.toLowerCase()

  const updateUserReq = (attribute, value) => {
    app.request('user:update', {
      attribute,
      value
    })
  }

  const onUsernameChange = async newUsername => {
    hideFlashUsername()
    if (currentUsername === newUsername) {
      // username has been modfied back to its original state
      // nothing to update and nothing to flash notify either
      return
    }
    if (newUsername.length < 2) {
      return showUsernameError('username should be 2 characters minimum')
    }
    if (newUsername.length > 20) {
      return showUsernameError('username should be 20 characters maximum')
    }
    if (/\s/.test(newUsername)) {
      return showUsernameError('username can not contain space')
    }
    if (/\W/.test(newUsername)) {
      return showUsernameError('username can only contain letters, figures or _')
    }
    await preq.get(app.API.auth.usernameAvailability(newUsername))
    .then(() => requestedUsername = newUsername)
    .catch(err => showFlashUsername({ priority: 'error', message: err.message }))
  }

  const showUsernameError = message => showFlashUsername({ priority: 'error', message: I18n(message) })

  const onBioChange = value => {
    hideFlashBio()
    bio = value
  }
  const updateBio = async () => {
    if (bio.length > 1000) {
      return showFlashBio({
        priority: 'error',
        message: I18n('presentation cannot be longer than 1000 characters')
      })
    }
    try {
      await updateUserReq('bio', bio)
      showFlashBio({
        priority: 'success',
        message: I18n('done')
      })
    } catch {
      showFlashBio({
        priority: 'error',
        message: I18n('something went wrong, try again later')
      })
    }
  }
</script>

<h2 class="title first-title">{I18n('public profile')}</h2>

<section>
  <h3 class="label">{I18n('username')}</h3>
  <div class="text-zone">
    <input placeholder="{i18n('username')}..." value={currentUsername} on:keyup="{e => onUsernameChange(e.target.value)}">
    <Flash bind:show={showFlashUsername} bind:hide={hideFlashUsername}/>
  </div>
  <p class="note">{I18n('username_tip')}</p>
  <button id="updateUsername" class="save light-blue-button" on:click="{updateUsername}">{I18n('update username')}</button>
</section>

<section>
  <h3 class="label">{I18n('presentation')}</h3>
  <div class="text-zone">
    <textarea name="bio" id="bio" aria-label="{i18n('presentation')}" on:keyup="{e => onBioChange(e.target.value)}">{bio}</textarea>
    <Flash bind:show={showFlashBio} bind:hide={hideFlashBio}/>
  </div>
  <p class="note">{I18n('a few words on you?')} ({bio.length}/1000)</p>
  <button id="saveBio" class="save light-blue-button" on:click="{() => updateBio(bio)}">{I18n('update presentation')}</button>
</section>

<style lang="scss">
  @import 'app/modules/settings/scss/section_settings_svelte';
</style>
