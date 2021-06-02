<script>
  import { I18n } from 'modules/user/lib/i18n'
  export let user
</script>
<section class="first-section">
  <h2 class="title">{I18n('data exports')}</h2>
  <h3 class="label">{I18n('inventory')}</h3>
  <p class="note">{I18n('download your inventory and its associated data (authors, works, publishers, etc.)')}</p>
  <button class="light-blue-button">
    <a href="/api/items?action=export&format=csv" download="inventory.csv">{I18n('download CSV')}</a>
  </button>
  <button class="light-blue-button">
    <a href="/api/items?action=by-users&users={user.id}&limit=100000" download="inventory.csv">{I18n('download JSON')}</a>
  </button>
  <h3 class="label">{I18n('user profile')}</h3>
  <p class="note">{I18n('all information stored about you, inside a JSON file')}</p>
  <button class="light-blue-button">
    <a href="/api/user" download="profile.csv">{I18n('download')}</a>
  </button>
</section>
<section>
  <h2 class="title">{I18n('API')}</h2>
  <a href="http://api.inventaire.io" target="_blank" class="link">{I18n('check the documentation')}</a>
</section>

<style lang="scss">
  @import 'app/modules/settings/scss/section_settings_svelte';
  button{
    margin-right:1em;
  }
</style>
