<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { BubbleUpComponentEvent } from '#app/lib/svelte/svelte'
  import Spinner from '#components/spinner.svelte'
  import ShelfLi from '#shelves/components/shelf_li.svelte'
  import { I18n } from '#user/lib/i18n'

  export let waitForShelves, shelves, user

  const { isMainUser } = user

  let showShelves = true

  let flash

  const toggleShelves = () => showShelves = !showShelves

  const dispatch = createEventDispatcher()
  const bubbleUpComponentEvent = BubbleUpComponentEvent(dispatch)
</script>

<div class="shelves-section">
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
</div>

<Flash state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
  .shelves-section{
    background-color: $light-grey;
  }
  .header{
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
  @media screen and (width < $smaller-screen){
    .subheader{
      @include display-flex(column, center);
      margin-block-end: 0.4em;
    }
  }
  #shelves-list ul{
    /* Large screens */
    @media screen and (width >= $smaller-screen){
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(25em, 1fr));
      gap: 0.5rem;
    }
    /* Small screens */
    @media screen and (width < $smaller-screen){
      :global(li){
        margin-block-end: 0.5rem;
      }
    }
    padding: 0 0.5rem 0.5rem;
  }
</style>
