<script lang="ts">
  import { API } from '#app/api/api'
  import { autosize } from '#app/lib/components/actions/autosize'
  import Flash from '#app/lib/components/flash.svelte'
  import { newError } from '#app/lib/error'
  import { imgSrc } from '#app/lib/image_source'
  import preq from '#app/lib/preq'
  import { Username } from '#app/lib/regex'
  import { onChange } from '#app/lib/svelte/svelte'
  import Modal from '#components/modal.svelte'
  import PicturePicker from '#components/picture_picker.svelte'
  import { askConfirmation } from '#general/lib/confirmation_modal'
  import UserPositionPicker from '#settings/components/user_position_picker.svelte'
  import { i18n, I18n } from '#user/lib/i18n'
  import { mainUserStore, updateUser } from '#user/lib/main_user'

  let bioState, usernameState
  let usernameValue = $mainUserStore.username
  let bioValue = $mainUserStore.bio || ''

  const showUsernameConfirmation = async () => {
    if ($mainUserStore.username === usernameValue) {
      usernameState = { type: 'info', message: 'this is already your username' }
      return
    }
    askConfirmation({
      confirmationText: i18n('username_change_confirmation', { currentUsername: $mainUserStore.username, requestedUsername: usernameValue }),
      // no need to show the warning if it's just a case change
      warningText: !doesUsernameCaseChange() ? i18n('username_change_warning') : undefined,
      action: updateUsername,
    })
  }

  async function updateUsername () {
    try {
      await updateUser('username', usernameValue)
    } catch (err) {
      usernameState = err
    }
  }

  const doesUsernameCaseChange = () => $mainUserStore.username.toLowerCase() === usernameValue.toLowerCase()

  const validateUsername = async () => {
    usernameState = null
    if ($mainUserStore.username.toLowerCase() === usernameValue.toLowerCase()) {
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
      return showUsernameError('username can not contain spaces')
    }
    if (!Username.test(usernameValue)) {
      return showUsernameError('username can only contain letters, figures or _')
    }
    const usernameValueBeforeCheck = usernameValue
    await preq.get(API.auth.usernameAvailability(usernameValue))
      .catch(err => {
        // Ignore errors when the requested username already changed
        if (usernameValueBeforeCheck === usernameValue) usernameState = err
      })
  }

  const showUsernameError = message => usernameState = newError(I18n(message), 400)

  const onBioChange = () => bioState = null

  const updateBio = async () => {
    if (bioValue.length > 1000) {
      bioState = newError(I18n('presentation cannot be longer than 1000 characters'), 400)
      return
    }
    if (bioValue === $mainUserStore.bio) {
      bioState = { type: 'info', message: 'this is already your bio' }
      return
    }
    try {
      bioState = { type: 'loading', message: I18n('waiting') }
      await updateUser('bio', bioValue)
      bioState = { type: 'success', message: I18n('done') }
    } catch (err) {
      bioState = err
    }
  }

  let showPositionPicker, showPicturePicker

  async function savePicture (imageHash) {
    await updateUser('picture', `/img/users/${imageHash}`)
  }
  async function deletePicture () {
    await updateUser('picture', null)
  }

  $: onChange(usernameValue, validateUsername)
  $: onChange(bioValue, onBioChange)
</script>

<form>
  <fieldset>
    <h2 class="first-title">{I18n('profile')}</h2>
    <h3>{I18n('username')}</h3>
    <div class="text-zone">
      <input
        type="text"
        placeholder="{i18n('username')}..."
        bind:value={usernameValue}
        name="username"
      />
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
        use:autosize></textarea>
      <Flash bind:state={bioState} />
    </div>
    <p class="note">
      {I18n('a few words on you?')}
      <span class="counter" class:alert={bioValue.length > 1000}>({bioValue.length}/1000)</span>
    </p>
    <button class="save light-blue-button" on:click={updateBio}>{I18n('update presentation')}</button>

    <h3>{I18n('profile picture')}</h3>
    <div>
      {#if $mainUserStore.picture}
        <img src={imgSrc($mainUserStore.picture, 250, 250)} alt={i18n('profile picture')} />
      {/if}
    </div>

    <button class="light-blue-button" on:click={() => showPicturePicker = true}>
      {I18n('change picture')}
    </button>

    <h3>{I18n('location')}</h3>
    <p class="position-status">
      {#if $mainUserStore.position}
        {I18n('position is set to')}: {$mainUserStore.position[0]}, {$mainUserStore.position[1]}
      {:else}
        {I18n('no position set')}
      {/if}
    </p>
    <p class="note">{I18n('position_settings_description')}</p>
    <button class="light-blue-button" on:click={() => showPositionPicker = true}>
      {#if $mainUserStore.position}
        {I18n('change position')}
      {:else}
        {I18n('add a position')}
      {/if}
    </button>
  </fieldset>
</form>

{#if showPicturePicker}
  <Modal on:closeModal={() => showPicturePicker = false}>
    <PicturePicker
      picture={$mainUserStore.picture}
      aspectRatio={1 / 1}
      imageContainer="users"
      {savePicture}
      {deletePicture}
      userContext={true}
      on:close={() => showPicturePicker = false}
    />
  </Modal>
{/if}

<UserPositionPicker bind:showPositionPicker />

<style lang="scss">
  @import "#settings/scss/common_settings";
  .position-status{
    padding-block-end: 1em;
  }
  input, textarea{
    appearance: none;
    border: 1px solid #aaa;
    margin-block-end: 0;
  }
  .text-zone{
    max-width: 28em;
    margin-block-end: 0.2em;
  }
  h3{
    @include settings-h3;
  }
  .note{
    color: $grey;
    font-size: 0.9rem;
    margin-block-end: 1em;
  }
  .counter.alert{
    color: $soft-red;
  }
</style>
