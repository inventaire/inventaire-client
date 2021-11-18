<script>
  import { I18n } from 'modules/user/lib/i18n'
  import { icon } from 'lib/utils'
  export let user
</script>

<form>
  <fieldset>
    <h2 class="first-title">{I18n('data exports')}</h2>

    <h3>{I18n('inventory')}</h3>
    <p class="note">{I18n('download your inventory and its associated data (authors, works, publishers, etc.)')}</p>
    <a class="light-blue-button" href="/api/items?action=export&format=csv" download="inventory.csv">{I18n('download CSV')}</a>
    <a class="light-blue-button" href="/api/items?action=by-users&users={user.id}&limit=100000" download="inventory.json">{I18n('download JSON')}</a>

    <h3>{I18n('user profile')}</h3>
    <p class="note">{I18n('your profile contains information about you')}</p>
    <a class="light-blue-button" href="/api/user" download="profile.json">{I18n('download JSON')}</a>
  </fieldset>
  <fieldset>
    <h2>{I18n('API')}</h2>
    <a href="http://api.inventaire.io" target="_blank" class="link">{I18n('check the documentation')} {@html icon('link')}</a>
  </fieldset>
</form>

<style lang="scss">
  @import 'app/modules/settings/scss/common_settings';
  .link{
    text-decoration: underline;
  }
  .light-blue-button{
    display: inline-block;
    margin: 0.5em 1em 0.5em 0;
    color: white
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
</style>
