<script>
  import { i18n, I18n } from 'modules/user/lib/i18n'
  import preq from 'lib/preq'
  export let user
  let currentUsername = user.attributes.label
  let bio = user.attributes.bio || ''
  let requestedUsername

  const updateUsername = async () => {
    await app.execute('ask:confirmation', {
      confirmationText: i18n('username_change_confirmation', { requestedUsername, currentUsername }),
      // no need to show the warning if it's just a case change
      warningText: !doesUsernameCaseChange() ? i18n('username_change_warning') : undefined,
      action: updateUserReq('username', requestedUsername)
    })
    currentUsername = requestedUsername
  }

  const doesUsernameCaseChange = () => requestedUsername.toLowerCase() === currentUsername.toLowerCase()

  const updateUserReq = (attribute, value) => {
    app.request('user:update', {
      attribute,
      value
    })
  }

  const onUsernameChange = async newUsername => {
    if (currentUsername === newUsername) {
      // username has been modfied back to its original state
      // nothing to update and nothing to flash notify either
      return
    }

    await preq.get(app.API.auth.usernameAvailability(newUsername))
    .then(() => requestedUsername = newUsername)
  }

  const onBioChange = value => {
    bio = value
  }
  const updateBio = async () => {
    await updateUserReq('bio', bio)
  }
</script>

<h2 class="title first-title">{I18n('public profile')}</h2>

<section>
  <h3 class="label">{I18n('username')}</h3>
  <div class="text-zone">
    <input placeholder="{i18n('username')}..." value={currentUsername} on:keyup="{e => onUsernameChange(e.target.value)}">
  </div>
  <p class="note">{I18n('username_tip')}</p>
  <button id="updateUsername" class="save light-blue-button" on:click="{updateUsername}">{I18n('update username')}</button>
</section>

<section>
  <h3 class="label">{I18n('presentation')}</h3>
  <div class="text-zone">
    <textarea name="bio" id="bio" aria-label="{i18n('presentation')}" on:keyup="{e => onBioChange(e.target.value)}">{bio}</textarea>
  </div>
  <p class="note">{I18n('a few words on you?')} ({bio.length}/1000)</p>
  <button id="saveBio" class="save light-blue-button" on:click="{() => updateBio(bio)}">{I18n('update presentation')}</button>
</section>

<style lang="scss">
  @import 'app/modules/settings/scss/section_settings_svelte';
</style>
