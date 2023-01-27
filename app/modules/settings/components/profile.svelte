<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { autosize } from '#lib/components/actions/autosize'
  import preq from '#lib/preq'
  import Flash from '#lib/components/flash.svelte'
  import UserPicture from '#lib/components/user_picture.svelte'
  import { showMainUserPositionPicker } from '#map/lib/map'
  import { user } from '#user/user_store'
  import { Username } from '#lib/regex'
  import error_ from '#lib/error'
  import { looksLikeSpam } from '#lib/spam'

  let bioState, usernameState
  let usernameValue = $user.username
  let bioValue = $user.bio || ''

  const showUsernameConfirmation = async () => {
    if ($user.username === usernameValue) {
      usernameState = { type: 'info', message: 'this is already your username' }
      return
    }
    app.execute('ask:confirmation', {
      confirmationText: i18n('username_change_confirmation', { currentUsername: $user.username, requestedUsername: usernameValue }),
      // no need to show the warning if it's just a case change
      warningText: !doesUsernameCaseChange() ? i18n('username_change_warning') : undefined,
      action: updateUsername
    })
  }

  const updateUsername = async () => {
    try {
      await updateUserReq('username', usernameValue)
    } catch (err) {
      usernameState = err
    }
  }

  const doesUsernameCaseChange = () => $user.username.toLowerCase() === usernameValue.toLowerCase()

  const updateUserReq = async (attribute, value) => {
    return app.request('user:update', {
      attribute,
      value
    })
  }

  const validateUsername = async () => {
    usernameState = null
    if ($user.username.toLowerCase() === usernameValue.toLowerCase()) {
      // username has been modfied back to its original state
      // nothing to update and nothing to notify either
      return
    }
    if (usernameValue.length < 2) {
      return showUsernameError('username should be 2 characters minimum')
    }
    if (usernameValue.length > 20) {
      return showUsernameError('username should be 20 characters maximum')
    }
    if (/\s/.test(usernameValue)) {
      return showUsernameError('username can not contain space')
    }
    if (!Username.test(usernameValue)) {
      return showUsernameError('username can only contain letters, figures or _')
    }
    const usernameValueBeforeCheck = usernameValue
    await preq.get(app.API.auth.usernameAvailability(usernameValue))
      .catch(err => {
        // Ignore errors when the requested username already changed
        if (usernameValueBeforeCheck === usernameValue) usernameState = err
      })
  }

  const showUsernameError = message => usernameState = new Error(I18n(message))

  const onBioChange = value => bioState = null

  const updateBio = async () => {
    if (bioValue.length > 1000) {
      bioState = new Error(I18n('presentation cannot be longer than 1000 characters'))
      return
    }
    if (bioValue === $user.bio) {
      bioState = { type: 'info', message: 'this is already your bio' }
      return
    }
    if (looksLikeSpam(bioValue)) {
      error_.report('possible spam attempt', { bioValue })
      // Do not display an error message to not give a clue to spammers
      return
    }
    try {
      bioState = { type: 'loading', message: I18n('waiting') }
      await updateUserReq('bio', bioValue)
      bioState = { type: 'success', message: I18n('done') }
    } catch (err) {
      bioState = err
    }
  }
  const editPosition = () => {
    showMainUserPositionPicker()
  }

  $: validateUsername(usernameValue)
  $: onBioChange(bioValue)
</script>

<form>
  <fieldset>
    <h2 class="first-title">{I18n('profile')}</h2>
    <h3>{I18n('username')}</h3>
    <div class="text-zone">
      <input placeholder="{i18n('username')}..." bind:value={usernameValue} name="username" />
      <Flash bind:state={usernameState} />
    </div>
    <p class="note">{I18n('username_tip')}</p>
    <button class="light-blue-button" on:click={showUsernameConfirmation}>{I18n('update username')}</button>

    <h3>{I18n('presentation')}</h3>
    <div class="text-zone">
      <textarea
        name="bio"
        id="bio"
        aria-label={i18n('presentation')}
        bind:value={bioValue}
        use:autosize />
      <Flash bind:state={bioState} />
    </div>
    <p class="note">
      {I18n('a few words on you?')}
      <span class="counter" class:alert={bioValue.length > 1000}>({bioValue.length}/1000)</span>
    </p>
    <button class="save light-blue-button" on:click={updateBio}>{I18n('update presentation')}</button>

    <h3>{I18n('profile picture')}</h3>
    <UserPicture />

    <h3>{I18n('location')}</h3>
    <p class="position-status">
      {#if $user.position}
        {I18n('position is set to')}: {$user.position[0]}, {$user.position[1]}
      {:else}
        {I18n('no position set')}
      {/if}
    </p>
    <p class="note">{I18n('position_settings_description')}</p>
    <button class="light-blue-button" on:click={editPosition}>
      {#if $user.position}
        {I18n('change position')}
      {:else}
        {I18n('add a position')}
      {/if}
    </button>
  </fieldset>
</form>

<style lang="scss">
  @import "#settings/scss/common_settings";
  .position-status{
    padding-bottom: 1em;
  }
  input, textarea{
    appearance: none;
    border: 1px solid #aaa;
    margin-bottom: 0;
  }
  .text-zone{
    max-width: 28em;
    margin-bottom: 0.2em;
  }
  h3{
    @include settings-h3;
  }
  .note{
    color: $grey;
    font-size: 0.9rem;
    margin-bottom: 1em;
  }
  .counter.alert{
    color: $soft-red;
  }
</style>
