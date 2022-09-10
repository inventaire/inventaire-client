<script>
  import { i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { createEventDispatcher } from 'svelte'
  import { screen } from '#lib/components/stores/screen'
  import { onChange } from '#lib/svelte/svelte'

  const dispatch = createEventDispatcher()

  export let someEditions, itemsUsers

  let areNotOnlyMainUserItems

  const triggerMap = () => {
    dispatch('showMap')
    dispatch('scrollToItemsList')
  }

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
{#if someEditions && areNotOnlyMainUserItems}
  <div class="actions-wrapper">
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
      on:click={triggerMap}
      title={i18n('Show users who have these editions on a map')}
      class="action-button"
    >
      {@html icon('map-marker')}
      {i18n('Show books on a map')}
    </button>
  </div>
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  .actions-wrapper{
    @include display-flex(row, center, center);
    min-height: 2em;
    margin: 1em 0;
  }
  .action-button{
    @include tiny-button($light-grey, black);
    padding: 0.5em;
    margin: 0.3em;
  }
</style>
