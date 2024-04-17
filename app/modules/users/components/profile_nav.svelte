<script lang="ts">
  import app from '#app/app'
  import { isOpenedOutside } from '#app/lib/utils'
  import { i18n } from '#user/lib/i18n'

  export let user = null
  export let group = null
  export let profileSection = null
  export let focusedSection

  // TODO: recover items and listings count
  let inventoryPathname, listingsPathname, listingsCount, navEl

  if (user) {
    ;({ inventoryPathname, listingsPathname } = user)
  } else if (group) {
    ;({ inventoryPathname, listingsPathname } = group)
  }

  const showSection = (e, value) => {
    if (isOpenedOutside(e)) return
    profileSection = value
    if (user) {
      $focusedSection = { type: 'user' }
    } else {
      $focusedSection = { type: 'group' }
    }
    if (profileSection === 'inventory') {
      app.navigate(inventoryPathname, { pageSectionElement: navEl })
    } else if (profileSection === 'listings') {
      app.navigate(listingsPathname, { pageSectionElement: navEl })
    }
  }
</script>

<div class="profile-tabs" bind:this={navEl}>
  <a
    href={inventoryPathname}
    class="tab"
    class:highlighted={profileSection === 'inventory' || profileSection == null}
    on:click={e => showSection(e, 'inventory')}
  >
    <span class="label">{i18n('Inventory')}</span>
  </a>
  <a
    href={listingsPathname}
    class="tab"
    class:highlighted={profileSection === 'listings'}
    on:click={e => showSection(e, 'listings')}
  >
    <span class="label">{i18n('Lists')}</span>
    {#if listingsCount != null}
      <span class="count">{listingsCount}</span>
    {/if}
  </a>
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .profile-tabs{
    @include display-flex(row, center, center, wrap);
    margin-block-end: 0.5em;
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
      @include bg-hover-from-to(darken($light-grey, 10%), lighten($light-grey, 2%));
    }
    &:first-child{
      @include radius-left;
    }
    &:last-child{
      @include radius-right;
    }
  }
  .count{
    margin-inline-start: 0.5em;
    line-height: 1rem;
    padding: 0.2em;
    background-color: white;
    opacity: 0.7;
    @include radius;
  }
</style>
