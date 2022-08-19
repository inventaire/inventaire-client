<script>
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { getShelvesByOwner } from '#shelves/lib/shelves'
  import { slide } from 'svelte/transition'
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'
  import ShelfLi from '#shelves/components/shelf_li.svelte'

  export let username, delayBeforeScrollToSection

  let showShelves = true

  let shelves, flash

  const waitForList = getUserId(username)
    .then(getShelvesByOwner)
    .then(res => shelves = res)
    .catch(err => flash = err)

  async function getUserId (username) {
    if (!username) return app.user.id
    return app.request('get:userId:from:username', username)
  }

  const toggleShelves = () => showShelves = !showShelves

  function showItemsNotInAShelf () {
  }
</script>

<div class="header">
  {#await waitForList}
    <h3 class="subheader">{I18n('shelves')} <Spinner /></h3>
  {:then}
    <h3 class="subheader">{I18n('shelves')}</h3>
    {#if shelves.length > 0}
      <button
        class="no-shelves-items tiny-button soft-grey"
        on:click={showItemsNotInAShelf}
        >
        show items without shelf
      </button>
      <button
        class="toggle-button tiny-button light-grey"
        title={showShelves ? I18n('hide shelves') : I18n('show shelves')}
        aria-controls="shelves-list"
        on:click={toggleShelves}
      >
        {#if showShelves}
          {@html icon('chevron-up')}
        {:else}
          {@html icon('chevron-down')}
        {/if}
      </button>
    {/if}
  {/await}
</div>

<div id="shelves-list">
  {#if shelves?.length > 0}
    {#if showShelves}
      <ul transition:slide={{ duration: delayBeforeScrollToSection - 100 }}>
        {#each shelves as shelf}
          <ShelfLi {shelf} />
        {/each}
      </ul>
    {/if}
  {/if}
</div>

<Flash state={flash} />

<style lang="scss">
  @import '#general/scss/utils';
  .header{
    background-color: $light-grey;
    @include display-flex(row, center, space-between);
    margin-top: 0.5em;
    @include display-flex(row, top, space-between);
    padding: 0.8em 1em;
    button:not(:last-child){
      margin-right: 0.5em;
    }
  }
  .toggle-button{
    height: 2em;
    width: 2em;
    padding: 0;
    @include display-flex(row, center, center);
    :global(.fa){
      margin-bottom: 0.1em;
    }
  }
  .no-shelves-items{
  }
  .subheader{
    margin-top: 0;
    margin-bottom: 0;
    font-size: 1rem;
    @include sans-serif;
  }
  .subheader{
    flex: 1 0 0;
    padding-right: 0.8em;
    @include display-flex(row, center, space-between);
  }
  /*Smaller screens*/
  @media screen and (max-width: $smaller-screen) {
    .toggle-button{
      padding-right: 0.5em;
      padding: 1em;
    }
    .subheader{
      @include display-flex(column, center);
      margin-bottom: 0.4em;
    }
  }
</style>
