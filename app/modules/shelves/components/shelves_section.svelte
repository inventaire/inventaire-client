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
</script>

<div class="wrapper">
  {#await waitForList}
    <div class="waiting">
      <h3 class="subheader">{I18n('shelves')} <Spinner /></h3>
    </div>
  {:then}
    {#if shelves.length > 0}
      <button
        class="toggle-button"
        title={showShelves ? I18n('hide shelves') : I18n('show shelves')}
        aria-controls="shelves-list"
        on:click={toggleShelves}
      >
        <h3 class="subheader">{I18n('shelves')}</h3>
        {#if showShelves}
          {@html icon('chevron-up')}
        {:else}
          {@html icon('chevron-down')}
        {/if}
      </button>
      <div id="shelves-list">
        {#if showShelves}
          <ul transition:slide={{ duration: delayBeforeScrollToSection - 100 }}>
            {#each shelves as shelf}
              <ShelfLi {shelf} />
            {/each}
          </ul>
        {/if}
      </div>
    {/if}
  {/await}

  <Flash state={flash} />
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .toggle-button, .waiting{
    width: 100%;
    @include display-flex(row, center, space-between);
    margin-top: 0.5em;
    @include bg-hover($light-grey, 5%);
    @include display-flex(row, top, space-between);
    padding: 1em;
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
