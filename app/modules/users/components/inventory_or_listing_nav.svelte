<script>
  import { i18n } from '#user/lib/i18n'
  import app from '#app/app'
  import { isOpenedOutside } from '#lib/utils'

  export let userModel, groupModel, currentSection

  let inventoryPathname, listingsPathname, listingsCount

  const aggregateMembersListsCount = () => {
    const groupUsersModels = groupModel.members.models

    const sumsListingsCount = (sum, user) => {
      const newCount = user.get('listingsCount')
      return sum + newCount
    }
    return groupUsersModels.reduce(sumsListingsCount, 0)
  }

  if (userModel) {
    ;({ inventoryPathname, listingsPathname } = userModel.toJSON())
  } else if (groupModel) {
    ;({ inventoryPathname, listingsPathname } = groupModel.toJSON())
  }

  userModel?.waitingForInventoryStats?.then(() => {
    listingsCount = userModel.get('listingsCount')
  })
  groupModel?.waitForMembers?.then(() => {
    listingsCount = aggregateMembersListsCount()
  })

  const showSection = (e, section) => {
    if (isOpenedOutside(e)) return
    currentSection = section
    app.vent.trigger('show:inventory:or:listing:section', { section, userModel, groupModel })
  }
</script>
<div class="inventory-or-listing-tabs">
  <a
    href={inventoryPathname}
    id="inventory-tab"
    class="tab"
    class:highlighted={currentSection === 'inventory'}
    on:click={e => showSection(e, 'inventory')}
  >
    <span class="label">{i18n('Inventory')}</span>
  </a>
  <a
    href={listingsPathname}
    id="list-tab"
    class="tab"
    class:highlighted={currentSection === 'listings'}
    on:click={e => showSection(e, 'listings')}
  >
    <span class="label">{i18n('Lists')}</span>
    {#if listingsCount != null}
      <span class="count">{listingsCount}</span>
    {/if}
  </a>
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .inventory-or-listing-tabs{
    @include display-flex(row, center, center, wrap);
    margin-bottom: 0.5em;
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
    &:first-child{
      @include radius-left;
    }
    &:last-child{
      @include radius-right;
    }
  }
  .count{
    margin-left: 0.5em;
    line-height: 1rem;
    padding: 0.2em;
    background-color: white;
    opacity: 0.7;
    @include radius;
  }
</style>
