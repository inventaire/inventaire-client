<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { apiDoc } from '#lib/urls'
  import app from '#app/app'
  export let user
  const csvExportUrl = app.API.items.export({ format: 'csv' })
  const inventoryJsonUrl = app.API.items.byUsers({ ids: user.id, limit: 100000 })
</script>

<form>
  <fieldset>
    <h2 class="first-title">{I18n('data exports')}</h2>

    <h3>{i18n('Inventory')}</h3>
    <p class="note">{I18n('download your inventory and its associated data (authors, works, publishers, etc.)')}</p>
    <a class="light-blue-button" href={csvExportUrl} download="inventory.csv">{I18n('download CSV')}</a>
    <a class="light-blue-button" href={inventoryJsonUrl} download="inventory.json">{I18n('download JSON')}</a>

    <h3>{I18n('user profile')}</h3>
    <p class="note">{I18n('your profile contains information about you')}</p>
    <a class="light-blue-button" href="/api/user" download="profile.json">{I18n('download JSON')}</a>
  </fieldset>
  <fieldset>
    <h2>{i18n('API')}</h2>
    <a
      href={apiDoc}
      target="_blank"
      rel="noreferrer"
      class="link">
      {I18n('check the documentation')}
      {@html icon('link')}
    </a>
  </fieldset>
</form>

<style lang="scss">
  @import '#settings/scss/common_settings';
  .link{
    text-decoration: underline;
  }
  .light-blue-button{
    display: inline-block;
    margin: 0.5em 1em 0.5em 0;
    color: white
  }
  h3{
    @include settings-h3;
  }
  .note{
    color: $grey;
    font-size: 0.9rem;
    margin-bottom: 1em;
  }
</style>
