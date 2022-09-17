<script>
  import { i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { createEventDispatcher } from 'svelte'
  import { screen } from '#lib/components/stores/screen'
  import { onChange } from '#lib/svelte/svelte'
  import AddToDotDotDotMenu from '#entities/components/layouts/add_to_dot_dot_dot_menu.svelte'
  import Flash from '#lib/components/flash.svelte'

  const dispatch = createEventDispatcher()

  export let entity, editions, someEditions, itemsUsers

  let areNotOnlyMainUserItems, flash

  function hasUsersOtherThanMainUser () {
    if (itemsUsers.length === 0) return false
    if (_.isEqual(itemsUsers, [ app.user.id ])) return false
    return true
  }

  function assignIfNotOnlyMainUserItems () {
    areNotOnlyMainUserItems = hasUsersOtherThanMainUser()
  }

  const smallScreenThreshold = 1000

  $: onChange(itemsUsers, assignIfNotOnlyMainUserItems)
</script>

<div class="actions-wrapper">
  <AddToDotDotDotMenu
    {entity}
    {editions}
    {flash}
  />
  {#if someEditions && areNotOnlyMainUserItems}
    {#if $screen.isSmallerThan(smallScreenThreshold)}
      <button
        on:click={() => dispatch('scrollToItemsList')}
        title={i18n('Show users who have these editions')}
        class="action-button"
      >
        {@html icon('user')}
        {i18n('Show who has this book')}
        ({itemsUsers.length})
      </button>
    {/if}
    <button
      on:click={() => dispatch('showMapAndScrollToMap')}
      title={i18n('Show users who have these editions on a map')}
      class="action-button"
    >
      {@html icon('map-marker')}
      {i18n('Show books on a map')}
    </button>
  {/if}
</div>
<Flash state={flash} />

<style lang="scss">
  @import '#general/scss/utils';
  .actions-wrapper{
    @include display-flex(column, stretch, center);
    margin: 1em 0;
    .tiny-button, .action-button, :global(.add-to-listing-button){
      margin-bottom: 0.3em;
    }
    .tiny-button, .action-button, :global(.dropdown-button){
      text-align: start;
    }
  }
  .action-button{
    @include tiny-button($light-grey, black);
  }
</style>
