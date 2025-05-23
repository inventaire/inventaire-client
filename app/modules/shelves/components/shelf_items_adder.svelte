<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { debounce } from 'underscore'
  import { API } from '#app/api/api'
  import { icon } from '#app/lib/icons'
  import preq from '#app/lib/preq'
  import { onChange } from '#app/lib/svelte/svelte'
  import { commands } from '#app/radio'
  import InfiniteScroll from '#components/infinite_scroll.svelte'
  import { setLastShelves } from '#inventory/lib/add_helpers'
  import { getUserItems } from '#inventory/lib/queries'
  import ShelfItemCandidate from '#shelves/components/shelf_item_candidate.svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { mainUser } from '#user/lib/main_user'

  export let shelf

  let mode = 'last-items'
  const batchLength = 20
  const { _id: shelfId, name } = shelf
  let items, lastItemsParams, searchText
  const dispatch = createEventDispatcher()

  async function fetchMoreLastItems () {
    mode = 'last-items'
    if (lastItemsParams) {
      if (lastItemsParams.hasMore === false) return
    } else {
      lastItemsParams = {
        userId: mainUser?._id,
        items: [],
        limit: batchLength,
        offset: 0,
      }
    }
    await getUserItems(lastItemsParams)
    items = lastItemsParams.items
    lastItemsParams.offset += lastItemsParams.limit
  }

  let lastInput
  let searchOffset = 0
  let searchHasBeenNonEmpty = false
  let searchHasMore = false

  async function search () {
    const input = searchText?.trim() || ''
    if (input === '' && !searchHasBeenNonEmpty) return
    if (mode === 'search' && lastInput === input) {
      searchOffset += batchLength
    } else {
      searchOffset = 0
    }
    mode = 'search'
    lastInput = input
    if (input === '') {
      toggleToLastItems()
      return
    } else {
      searchHasBeenNonEmpty = true
    }

    const offset = searchOffset
    const res = await preq.get(API.items.search({
      user: mainUser?._id,
      search: input,
      limit: batchLength,
      offset,
    }))

    if (lastInput === input) {
      if (offset === 0) {
        items = res.items
      } else {
        items = items.concat(res.items)
      }
    }
    searchHasMore = (res.items.length === batchLength)
  }

  const lazySearch = debounce(search, 200)

  $: onChange(searchText, lazySearch)

  function toggleToLastItems () {
    mode = 'last-items'
    items = lastItemsParams.items
  }

  async function keepScrolling () {
    if (mode === 'last-items') {
      await fetchMoreLastItems()
      return lastItemsParams.hasMore
    } else {
      await lazySearch()
      return searchHasMore
    }
  }

  function addNewItems () {
    setLastShelves([ shelfId ])
    dispatch('shelfItemsAdderDone')
    commands.execute('show:add:layout')
  }

  function done () {
    dispatch('shelfItemsAdderDone')
  }
</script>

<div class="shelf-items-adder">
  <h4>{name}</h4>

  <input
    type="search"
    placeholder="{I18n('search_verb')}..."
    bind:value={searchText}
  />

  <ul class="shelf-items-candidates">
    <InfiniteScroll {keepScrolling} showSpinner={true}>
      {#if items}
        {#each items as item (item._id)}
          <ShelfItemCandidate bind:item {shelfId} />
        {:else}
          <p class="no-suggestion">{i18n('no suggestion found')}</p>
        {/each}
      {/if}
    </InfiniteScroll>
  </ul>

  <div class="buttons">
    <button
      class="add-new-items action button light-blue"
      title={I18n('add a new book to this shelf')}
      on:click={addNewItems}
    >
      {@html icon('plus')} {I18n('add new books')}
    </button>
    <button
      class="done button success-button"
      on:click={done}
    >
      {@html icon('check')}
      {I18n('done')}
    </button>
  </div>
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .shelf-items-adder{
    @include display-flex(column, center, center);
  }
  .no-suggestion{
    color: $grey;
  }
  .buttons{
    @include display-flex(row, center, space-around);
    margin-block-start: 1em;
    align-self: stretch;
    button{
      padding: 0.7em;
      text-align: center;
      flex: 1;
      font-weight: bold;
    }
    .add-new-items{
      padding: 0.7em 0.6em;
    }
  }

  .shelf-items-candidates{
    max-height: 50vh;
    overflow-y: auto;
    align-self: stretch;
    .no-suggestion{
      text-align: center;
    }
  }

  input[type="search"]{
    max-width: 20em;
  }

  /* Smaller screens */
  @media screen and (width < $smaller-screen){
    .buttons{
      padding: 0 1em;
      flex-direction: column;
      align-items: stretch;
      .add-new-items{
        margin-block-end: 1em;
      }
    }
  }

  /* Large screens */
  @media screen and (width >= $smaller-screen){
    .done{
      margin-inline-start: 0.5em;
    }
  }
</style>
