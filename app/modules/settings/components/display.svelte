<script>
  import { I18n, i18n } from 'modules/user/lib/i18n'
  import { localStorageProxy } from 'lib/local_storage'
  export let entitiesLarge, inventoryCascade, entitiesCompact, inventoryTable
  const entitiesDisplay = localStorageProxy.getItem('entitiesDisplay') || 'entitiesLarge'
  const inventoryDisplay = localStorageProxy.getItem('inventoryDisplay') || 'inventoryCascade'

  entitiesDisplay === 'compact' ? entitiesCompact = true : entitiesLarge = true
  inventoryDisplay === 'table' ? inventoryTable = true : inventoryCascade = true

  const selectDisplay = (type, value) => localStorageProxy.setItem(type, value)
</script>

<div class="wrapper">
  <h2 class="first-title">{I18n('display_name')}</h2>
  <section class="first-section">
    <label for="entitiesDisplay">{I18n('entities lists')} ({i18n('works')})</label>
    <select id="entitiesDisplay" on:blur="{e => selectDisplay('entitiesDisplay', e.target.value)}">
      <option value="large" selected="{entitiesLarge}">{I18n('large')}</option>
      <option value="compact" selected="{entitiesCompact}">{I18n('compact')}</option>
    </select>
  </section>
  <section>
    <label for="inventoryDisplay">{i18n('inventory lists')}</label>
    <select id="inventoryDisplay" on:blur="{e => selectDisplay('inventoryDisplay', e.target.value)}">
      <option value="cascade" selected="{inventoryCascade}">{I18n('cascade')}</option>
      <option value="table" selected="{inventoryTable}">{I18n('table')}</option>
    </select>
  </section>
</div>

<style lang="scss">
  @import 'app/modules/settings/scss/common_settings';
  .wrapper{
    margin: 0 1.5em;
  }
  section{
    padding-left: 0;
  }
</style>
