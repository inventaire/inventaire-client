<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import assert_ from '#app/lib/assert_types'
  import Flash from '#app/lib/components/flash.svelte'
  import { BubbleUpComponentEvent, onChange } from '#app/lib/svelte/svelte'
  import InfiniteScroll from '#components/infinite_scroll.svelte'
  import Spinner from '#components/spinner.svelte'
  import ItemsCascade from '#inventory/components/items_cascade.svelte'
  import ItemsTable from '#inventory/components/items_table.svelte'
  import { i18n } from '#user/lib/i18n'

  export let display
  export let pagination
  export let itemsIds = null
  export let shelfId = null
  export let itemsShelvesByIds = null
  export let isMainUser = false
  export let showDistance = false
  export let haveSeveralOwners = false

  let waiting, fetchMore, hasMore, allowMore, flash, total
  let items = null
  let fetching = false

  async function fetch () {
    try {
      if (fetching) return
      fetching = true
      waiting = fetchMore()
      await waiting
      assert_.array(pagination.items)
      items = pagination.items
      // TODO: make the pagination object more consistent among cases
      total = pagination.moreData?.total || pagination.total || items.length
      fetching = false
    } catch (err) {
      flash = err
    }
  }

  async function keepScrolling () {
    if (!(allowMore && hasMore())) return false
    await fetch()
    return true
  }

  function reinitializePagination () {
    if (!pagination) return
    ;({ fetchMore, hasMore, allowMore } = pagination)
    if (!pagination.firstFetchDone) {
      pagination.firstFetchDone = true
      items = null
      fetch()
    }
  }

  $: onChange(pagination, reinitializePagination)

  const dispatch = createEventDispatcher()
  const bubbleUpComponentEvent = BubbleUpComponentEvent(dispatch)
</script>

<InfiniteScroll {keepScrolling}>
  <div class="paginated-items">
    {#if items?.length > 0}
      {#if display === 'cascade'}
        <ItemsCascade
          {items}
          {showDistance}
          {waiting}
          {shelfId}
        />
      {:else if display === 'table'}
        <ItemsTable
          {items}
          {itemsShelvesByIds}
          {isMainUser}
          {shelfId}
          {itemsIds}
          {waiting}
          {haveSeveralOwners}
          on:selectShelf={bubbleUpComponentEvent}
        />
      {/if}
    {:else if total === 0}
      <p class="no-item">{i18n('There is nothing here')}</p>
    {:else}
      <div class="spinner-wrapper">
        <Spinner center={true} />
      </div>
    {/if}
    <Flash state={flash} />
  </div>
</InfiniteScroll>

<style lang="scss">
  @import "#general/scss/utils";
  .paginated-items{
    min-height: 20em;
  }
  // Use a wrapping div to limit the global rule to just that spinner
  .spinner-wrapper{
    :global(.spinner){
      margin: 1em;
    }
  }
  .no-item{
    text-align: center;
    color: $grey;
    margin: 1em;
  }
</style>
