<script>
  import { i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { createEventDispatcher } from 'svelte'
  import screen_ from '#lib/screen'

  const dispatch = createEventDispatcher()

  export let someEditions, usersSize

  const triggerMap = () => {
    dispatch('showMap')
    dispatch('scrollToItemsList')
  }
</script>
{#if someEditions && usersSize > 0}
  <div class="actions-wrapper">
    {#if screen_.isSmall(600)}
      <button
        on:click={() => dispatch('scrollToItemsList')}
        title={i18n('Show users who have these editions')}
        class="action-button"
      >
        {@html icon('user')}
        {i18n('Show who has this book')}
        ({usersSize})
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
