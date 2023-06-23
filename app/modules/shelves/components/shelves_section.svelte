<script>
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'
  import ShelfLi from '#shelves/components/shelf_li.svelte'
  import { BubbleUpComponentEvent } from '#lib/svelte/svelte'
  import { createEventDispatcher } from 'svelte'

  export let waitForShelves, shelves, user

  const { isMainUser } = user

  let showShelves = true

  let flash

  const toggleShelves = () => showShelves = !showShelves

  const dispatch = createEventDispatcher()
  const bubbleUpComponentEvent = BubbleUpComponentEvent(dispatch)
</script>

{#await waitForShelves}
  <div class="header">
    <h3 class="subheader">{I18n('shelves')} <Spinner /></h3>
  </div>
{:then}
  {#if shelves.length > 0}
    <div class="header">
      <h3 class="subheader">{I18n('shelves')}</h3>
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
    </div>
  {/if}
{/await}

<div id="shelves-list">
  {#if shelves?.length > 0}
    {#if showShelves}
      <ul>
        {#each shelves as shelf (shelf._id)}
          <ShelfLi {shelf} on:selectShelf={bubbleUpComponentEvent} />
        {/each}
        {#if isMainUser}
          <ShelfLi withoutShelf={true} on:selectShelf={bubbleUpComponentEvent} />
        {/if}
      </ul>
    {/if}
  {/if}
</div>

<Flash state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
  .header{
    background-color: $light-grey;
    @include display-flex(row, center, space-between);
    margin-block-start: 0.5em;
    @include display-flex(row, top, space-between);
    padding: 0.8em 1em;
    button:not(:last-child){
      margin-inline-end: 0.5em;
    }
  }
  .toggle-button{
    height: 2em;
    width: 2em;
    padding: 0;
    @include display-flex(row, center, center);
    :global(.fa){
      margin-block-end: 0.1em;
    }
  }
  .subheader{
    margin-block: 0;
    font-size: 1rem;
    @include sans-serif;
    flex: 1 0 0;
    padding-inline-end: 0.8em;
    @include display-flex(row, center, space-between);
  }
  /* Smaller screens */
  @media screen and (max-width: $smaller-screen){
    .toggle-button{
      padding: 1em 0.5em 1em 1em;
    }
    .subheader{
      @include display-flex(column, center);
      margin-block-end: 0.4em;
    }
  }
</style>
