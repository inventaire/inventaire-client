<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import Flash from '#app/lib/components/flash.svelte'
  import { screen } from '#app/lib/components/stores/screen'
  import { icon } from '#app/lib/icons'
  import { onChange } from '#app/lib/svelte/svelte'
  import type { Align } from '#components/dropdown.svelte'
  import AddToDotDotDotMenu from '#entities/components/layouts/add_to_dot_dot_dot_menu.svelte'
  import type { SerializedEntity } from '#entities/lib/entities'
  import type { SerializedItemWithUserData } from '#inventory/lib/items'
  import { i18n } from '#user/lib/i18n'

  const dispatch = createEventDispatcher()

  export let entity: SerializedEntity
  export let editions: SerializedEntity[] = null
  export let someEditions = false
  export let allItems: SerializedItemWithUserData[] = null
  export let align: Align = null

  let otherUsersItems, areNotOnlyMainUserItems, someOtherUsersItemsHaveAPosition, flash

  function determineUsefulButtons () {
    if (!allItems) return
    const otherUsersItems = allItems.filter(item => !item.mainUserIsOwner)
    areNotOnlyMainUserItems = otherUsersItems.length > 0
    someOtherUsersItemsHaveAPosition = otherUsersItems.find(item => item.distanceFromMainUser != null)
  }

  $: onChange(allItems, determineUsefulButtons)
</script>

<div class="actions-wrapper">
  <AddToDotDotDotMenu
    {entity}
    {editions}
    {flash}
    {align}
  />
  {#if someEditions && areNotOnlyMainUserItems}
    {#if $screen.isSmallerThan('$small-screen')}
      <button
        on:click={() => dispatch('scrollToItemsList')}
        title={i18n('Show users who have these editions')}
        class="action-button"
      >
        {@html icon('user')}
        {i18n('Show who has this book')}
        {#if otherUsersItems}({otherUsersItems.length}){/if}
      </button>
    {/if}
    {#if someOtherUsersItemsHaveAPosition}
      <button
        on:click={() => dispatch('showMapAndScrollToMap')}
        title={i18n('Show users who have these editions on a map')}
        class="action-button"
      >
        {@html icon('map-marker')}
        {i18n('Show books on a map')}
      </button>
    {/if}
  {/if}
</div>
<Flash state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
  .actions-wrapper{
    @include display-flex(column, stretch, center);
    margin: 1em 0;
    min-inline-size: 10em;
    .action-button, :global(.add-to-dot-dot-dot-menu){
      margin-block-end: 0.3em;
    }
    .action-button, :global(.add-to-dot-dot-dot-menu-button){
      text-align: end;
    }
    .action-button, :global(.dropdown-button){
      text-align: start;
    }
  }
  .action-button{
    @include tiny-button($light-grey, black);
  }
  /* Small screens */
  @media screen and (width < $smaller-screen){
    .actions-wrapper{
      @include display-flex(row);
    }
  }
</style>
