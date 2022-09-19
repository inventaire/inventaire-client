<script>
  import { i18n } from '#user/lib/i18n'
  import app from '#app/app'

  export let userModel, currentSection
  const { pathname, username } = userModel.toJSON()

  const showSection = section => {
    currentSection = section
    app.vent.trigger('show:inventory:or:listing:section', { section, userModel })
  }
</script>
<div class="inventoryOrListingTabs">
  <a
    href={pathname}
    id="inventory-tab"
    class="tab"
    class:highlighted={currentSection === 'inventory'}
    on:click={() => showSection('inventory')}
  >
    <span class="label">{i18n('Inventory')}</span>
  </a>
  <a
    href={`/lists/${username}`}
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
  .inventoryOrListingTabs{
    @include display-flex(row, center, center, wrap);
    margin-bottom: 0.5em;
  }
  .tab{
    flex: 1 0 auto;
    @include bg-hover($dark-grey);
    color: white;
    font-weight: bold;
    padding: 0.5em;
    align-self: stretch;
    @include display-flex(row, center, center);
  }
  .highlighted{
    color: $dark-grey;
    @include bg-hover($light-grey);
  }
</style>
