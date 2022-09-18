<script>
  import { i18n } from '#user/lib/i18n'
  import app from '#app/app'

  export let userModel
  const { pathname, username } = userModel.toJSON()
</script>
<div class="inventoryOrListingTabs">
  <a
    href={pathname}
    id="inventory-tab"
    class="tab"
    on:click={app.vent.trigger('show:inventory:or:listing:section', { section: 'inventory', userModel })}
  >
    <span class="label">{i18n('Inventory')}</span>
  </a>
  <a
    href={`/lists/${username}`}
    id="list-tab"
    class="tab"
    on:click={app.vent.trigger('show:inventory:or:listing:section', { section: 'listings', userModel })}
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
    @include bg-hover-lighten($light-grey);
    font-weight: bold;
    padding: 0.5em;
    align-self: stretch;
    @include display-flex(row, center, center);
  }
</style>
