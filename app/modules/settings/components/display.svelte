<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { getLocalStorageStore } from '#lib/components/stores/local_storage_stores'
  import DisplayedLinks from '#settings/components/displayed_links.svelte'

  const entitiesDisplay = getLocalStorageStore('entitiesDisplay', 'large')
  const inventoryDisplay = getLocalStorageStore('inventoryDisplay', 'cascade')
</script>

<form>
  <h2 class="first-title">{I18n('display_name')}</h2>
  <fieldset>
    <label for="entitiesDisplay">{I18n('entities lists')} ({i18n('works')})</label>
    <select id="entitiesDisplay" bind:value={$entitiesDisplay}>
      <option value="large">{I18n('large')}</option>
      <option value="compact">{I18n('compact')}</option>
    </select>
  </fieldset>
  <fieldset>
    <label for="inventoryDisplay">{i18n('inventory lists')}</label>
    <select id="inventoryDisplay" bind:value={$inventoryDisplay}>
      <option value="cascade">{I18n('cascade')}</option>
      <option value="table">{I18n('table')}</option>
    </select>
  </fieldset>

  <h3>{I18n('links')}</h3>
  <DisplayedLinks />
</form>

<style lang="scss">
  @import '#settings/scss/common_settings';
  form{
    margin: 0 1.5em;
  }
  fieldset{
    padding-left: 0;
  }
  label{
    font-size: 1rem;
  }
  h3{
    @include settings-h3;
  }
</style>
