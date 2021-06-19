<script>
  import { i18n, I18n } from 'modules/user/lib/i18n'
  import { autosize } from 'lib/components/actions/autosize'
  import preq from 'lib/preq'
  import Flash from 'lib/components/flash.svelte'
  import UserPicture from 'lib/components/user_picture.svelte'
  import map from 'modules/map/lib/map'

  export let user
  let bioState, usernameState
  let currentUsername = user.get('username')
  let usernameValue = currentUsername
  let bioValue = user.get('bio') || ''
  let currentBio = bioValue
  let currentPicture = user.get('picture')
  const position = user.get('position')

  const showUsernameConfirmation = async () => {
    if (currentUsername === usernameValue) {
      usernameState = { type: 'info', message: 'this is already your username' }
      return
    }
    app.execute('ask:confirmation', {
      confirmationText: i18n('username_change_confirmation', { currentUsername, requestedUsername: usernameValue }),
      // no need to show the warning if it's just a case change
      warningText: !doesUsernameCaseChange() ? i18n('username_change_warning') : undefined,
      action: updateUsername
    })
  }

  const updateUsername = async () => {
    try {
      await updateUserReq('username', usernameValue)
      currentUsername = usernameValue
    } catch (err) {
      usernameState = err
    }
  }

  const doesUsernameCaseChange = () => currentUsername.toLowerCase() === usernameValue.toLowerCase()

  const updateUserReq = async (attribute, value) => {
    return app.request('user:update', {
      attribute,
      value
    })
  }

  const validateUsername = async newUsername => {
    usernameState = null
    if (currentUsername === newUsername) {
      // username has been modfied back to its original state
      // nothing to update and nothing to notify either
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
    .catch(err => usernameState = err)
  }

  const showUsernameError = message => usernameState = new Error(I18n(message))

  const onBioChange = value => bioState = null

  const updateBio = async () => {
    if (bioValue.length > 1000) {
      bioState = new Error(I18n('presentation cannot be longer than 1000 characters'))
      return
    }
    if (bioValue === currentBio) {
      bioState = { type: 'info', message: 'this is already your bio' }
      return
    }
    try {
      bioState = { type: 'loading', message: I18n('waiting') }
      await updateUserReq('bio', bioValue)
      bioState = { type: 'success', message: I18n('done') }
      currentBio = bioValue
    } catch (err) {
      bioState = err
    }
  }
  const editPosition = () => {
    map.showMainUserPositionPicker()
  }

  $: validateUsername(usernameValue)
  $: onBioChange(bioValue)
</script>

<section class="first-section">
  <h2 class="first-title">{I18n('public profile')}</h2>
  <h3>{I18n('username')}</h3>
  <div class="text-zone">
    <input placeholder="{i18n('username')}..." bind:value={usernameValue}>
    <Flash bind:state={usernameState}/>
  </div>
  <p class="note">{I18n('username_tip')}</p>
  <button class="light-blue-button" on:click={showUsernameConfirmation}>{I18n('update username')}</button>

  <h3>{I18n('presentation')}</h3>
  <div class="text-zone">
    <textarea name="bio" id="bio" aria-label="{i18n('presentation')}" bind:value={bioValue} use:autosize></textarea>
    <Flash bind:state={bioState}/>
  </div>
  <p class="note">
    {I18n('a few words on you?')}
    <span class="counter" class:alert="{bioValue.length > 1000}">({bioValue.length}/1000)</span>
  </p>
  <button class="save light-blue-button" on:click={updateBio}>{I18n('update presentation')}</button>
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
  <p class="note">{I18n('position_settings_description')}</p>
  <button class="light-blue-button" on:click={editPosition}>
    {#if position}
      {I18n('change position')}
    {:else}
      {I18n('add a position')}
    {/if}
  </button>
</section>

<style lang="scss">
  @import 'app/modules/settings/scss/common_settings';
  .position-status{
    padding-bottom: 1em;
  }
  input, textarea{
    appearance: none;
    border: 1px solid #AAA;
    margin-bottom: 0;
  }
  .text-zone{
    max-width: 28em;
    margin-bottom: 0.2em;
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
  .counter.alert{
    color: $soft-red;
  }
</style>
