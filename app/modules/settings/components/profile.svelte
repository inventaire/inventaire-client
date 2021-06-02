<script>
  import { i18n, I18n } from 'modules/user/lib/i18n'
  import preq from 'lib/preq'
  import Flash from 'lib/components/flash.svelte'
  import UserPicture from 'lib/components/user_picture.svelte'
  import map from 'modules/map/lib/map'
  export let user
  let showFlashBio, showFlashUsername, hideFlashUsername, hideFlashBio
  let currentUsername = user.get('label')
  let requestedUsername
  let bio = user.get('bio') || ''
  let currentPicture = user.get('picture')
  const position = user.get('position')

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
  const editPosition = () => {
    map.showMainUserPositionPicker()
  }
</script>

<section class="first-section">
  <h2 class="first-title">{I18n('public profile')}</h2>
  <h3>{I18n('username')}</h3>
  <div class="text-zone">
    <input placeholder="{i18n('username')}..." value={currentUsername} on:keyup="{e => onUsernameChange(e.target.value)}">
    <Flash bind:show={showFlashUsername} bind:hide={hideFlashUsername}/>
  </div>
  <p class="note">{I18n('username_tip')}</p>
  <button class="light-blue-button" on:click="{updateUsername}">{I18n('update username')}</button>
  <h3>{I18n('presentation')}</h3>
  <div class="text-zone">
    <textarea name="bio" id="bio" aria-label="{i18n('presentation')}" on:keyup="{e => onBioChange(e.target.value)}">{bio}</textarea>
    <Flash bind:show={showFlashBio} bind:hide={hideFlashBio}/>
  </div>
  <p class="note">{I18n('a few words on you?')} ({bio.length}/1000)</p>
  <button class="save light-blue-button" on:click="{() => updateBio(bio)}">{I18n('update presentation')}</button>
</section>

<section>
  <h2>{I18n('profile picture')}</h2>
  <UserPicture bind:currentPicture={currentPicture}/>
</section>

<section>
  <h2>{I18n('location')}</h2>
  <p class="position-status">
    {#if position}
      {i18n('position is set to')}: {position[0]}, {position[1]}
    {:else}
      {i18n('no position set')}
    {/if}
  </p>
  <button class="light-blue-button" on:click={editPosition}>
    {#if position}
      {I18n('change position')}
    {:else}
      {I18n('add a position')}
    {/if}
  </button>
</section>

<section>
  <h2>{I18n('download your profile')}</h2>
  <p class="note">{I18n('an export of all information stored about you, inside a JSON file. For more exports, see the "Data" section of the current settings')}</p>
  <button class="light-blue-button">
    <a href="/api/user" download="profile.csv">{I18n('download')}</a>
  </button>
</section>


<style lang="scss">
  @import 'app/modules/settings/scss/section_settings_svelte';
  .position-status{
    padding-bottom: 1em;
  }
  input, textarea{
    appearance: none;
    border: 1px solid #AAA;
    margin-bottom: 0;
  }
  .text-zone{
    max-width: 25em;
    margin-bottom: 0.2em;
  }
  button a {
    color: white
  }
</style>
