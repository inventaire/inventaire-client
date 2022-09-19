<script>
  import { i18n } from '#user/lib/i18n'
  import app from '#app/app'

  export let userModel, groupModel, currentSection

  let inventoryPathname, listingsPathname

  if (userModel) {
    ;({ inventoryPathname, listingsPathname } = userModel.toJSON())
  } else if (groupModel) {
    ;({ inventoryPathname, listingsPathname } = groupModel.toJSON())
  }

  const showSection = section => {
    currentSection = section
    app.vent.trigger('show:inventory:or:listing:section', { section, userModel })
  }
</script>
<div class="inventory-or-listing-tabs">
  <a
    href={inventoryPathname}
    id="inventory-tab"
    class="tab"
    class:highlighted={currentSection === 'inventory'}
    on:click={() => showSection('inventory')}
  >
    <span class="label">{i18n('Inventory')}</span>
  </a>
  <a
    href={listingsPathname}
    id="list-tab"
    class="tab"
    class:highlighted={currentSection === 'listings'}
    on:click={() => showSection('listings')}
  >
    <span class="label">{i18n('Lists')}</span>
  </a>
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .inventory-or-listing-tabs{
    @include display-flex(row, center, center, wrap);
    margin-bottom: 0.5em;
    @include radius-horizontal-group;
  }
  .tab{
    flex: 1 0 auto;
    color: $default-text-color;
    font-weight: bold;
    padding: 0.5em;
    align-self: stretch;
    @include display-flex(row, center, center);
    &.highlighted{
      background-color: $light-grey;
    }
    &:not(.highlighted){
      @include bg-hover(darken($light-grey, 10%));
    }
  }
</style>
