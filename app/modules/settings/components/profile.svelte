<script>
  import { i18n, I18n } from 'modules/user/lib/i18n'
  export let user
  const username = user.attributes.label
  const bio = user.attributes.bio || ''
</script>
<h2 class="title first-title">{I18n('public profile')}</h2>

<section>
  <h3 class="label">{I18n('username')}</h3>
  <input placeholder="{i18n('username')}..." value={username}>
  <p class="note">{I18n('username_tip')}</p>
  <button id="saveUsername" class="save light-blue-button">{I18n('update name')}</button>
</section>

<section>
  <h3 class="label">{I18n('presentation')}</h3>
  <textarea name="bio" id="bio" class="ctrlEnterClick" aria-label="{i18n('presentation')}">{bio}</textarea>
  <div class="bioLimit"></div>
  <p class="note">{I18n('a few words on you?')}</p>
  <button id="saveBio" class="save light-blue-button">{I18n('update presentation')}</button>
</section>

<style lang="scss">
  @import 'app/modules/settings/scss/section_settings_svelte';
</style>
