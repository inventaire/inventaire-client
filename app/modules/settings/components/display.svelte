<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { getLocalStorageStore } from '#lib/components/stores/local_storage_stores'
  import DisplayedLinks from '#settings/components/displayed_links.svelte'

  const entitiesDisplay = getLocalStorageStore('entitiesDisplay', 'large')
  const mainUserInventoryDisplay = getLocalStorageStore('mainUserInventoryDisplay', 'table')
  const inventoryDisplay = getLocalStorageStore('inventoryDisplay', 'cascade')
</script>

<form>
  <h2 class="first-title">{I18n('display_name')}</h2>

  <h3>{i18n('Inventories')}</h3>
  <fieldset>
    <label for="mainUserInventoryDisplay">{i18n('Your inventory')}</label>
    <select id="mainUserInventoryDisplay" bind:value={$mainUserInventoryDisplay}>
      <option value="cascade">{I18n('cascade')}</option>
      <option value="table">{I18n('table')}</option>
    </select>
  </fieldset>

  <fieldset>
    <label for="inventoryDisplay">{i18n("Other users' inventories")}</label>
    <select id="inventoryDisplay" bind:value={$inventoryDisplay}>
      <option value="cascade">{I18n('cascade')}</option>
      <option value="table">{I18n('table')}</option>
    </select>
  </fieldset>

  <h3>{i18n('Biblographic data')}</h3>
  <fieldset>
    <label for="entitiesDisplay">{I18n('entities lists')} ({i18n('works')})</label>
    <select id="entitiesDisplay" bind:value={$entitiesDisplay}>
      <option value="large">{I18n('large')}</option>
      <option value="compact">{I18n('compact')}</option>
    </select>
  </fieldset>

  <h4>{i18n('Displayed links')}</h4>
  <DisplayedLinks />
</form>

<style lang="scss">
  @import "#settings/scss/common_settings";
  form{
    margin: 0 1.5em;
  }
  fieldset{
    padding-inline-start: 0;
    padding-block-start: 1rem;
  }
  label{
    font-size: 1rem;
  }
  h3{
    @include settings-h3;
  }
  h3 + fieldset{
    padding-block-start: 0;
  }
  h4{
    margin-block-start: 1rem;
    font-size: 1rem;
    font-weight: bold;
    @include sans-serif;
  }
</style>
