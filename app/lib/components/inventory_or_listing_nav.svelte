<script>
  import { i18n } from '#user/lib/i18n'
  import app from '#app/app'

  export let userModel, groupModel, currentSection

  let pathname, name

  if (userModel) {
    const user = userModel.toJSON()
    pathname = user.pathname
    name = user.username
  } else if (groupModel) {
    const group = groupModel.toJSON()
    pathname = group.pathname
    name = group.name
}

  const showSection = section => {
    currentSection = section
    app.vent.trigger('show:inventory:or:listing:section', { section, userModel })
  }
</script>
<div class="inventory-or-listing-tabs">
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
    href={`/lists/${name}`}
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
