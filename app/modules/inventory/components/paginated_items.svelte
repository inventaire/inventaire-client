<script>
  import Flash from '#lib/components/flash.svelte'
  import viewport from '#lib/components/actions/viewport'
  import { wait } from '#lib/promises'
  import { onChange } from '#lib/svelte/svelte'
  import assert_ from '#lib/assert_types'
  import { i18n } from '#user/lib/i18n'
  import Spinner from '#components/spinner.svelte'
  import ItemsTable from '#inventory/components/items_table.svelte'
  import ItemsCascade from '#inventory/components/items_cascade.svelte'

  export let display
  export let pagination
  export let itemsIds = null
  export let shelfId = null
  export let itemsShelvesByIds = null
  export let isMainUser = false
  export let showDistance = false
  export let haveSeveralOwners = false

  let waiting, fetchMore, hasMore, allowMore, flash
  let items = null
  let fetching = false

  async function fetch () {
    fetching = true
    waiting = fetchMore()
      .then(() => {
        assert_.array(pagination.items)
        items = pagination.items
        fetching = false
      })
      .catch(err => flash = err)
  }

  let bottomElInView = false
  async function bottomIsInViewport () {
    bottomElInView = true
    if (fetching || !(allowMore && hasMore())) return
    await fetch()
    // Let the time to fetched items to render
    await wait(500)
    // But if the bottom is still in viewport
    // when the new items are rendered, fetch more
    if (bottomElInView) bottomIsInViewport()
  }

  function bottomLeftViewport () {
    bottomElInView = false
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
</script>

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
      />
    {/if}
  {:else}
    {#await waiting}
      <Spinner center={true} />
    {:then}
      {#if items?.length === 0}
        <p class="no-item">{i18n('There is nothing here')}</p>
      {/if}
    {/await}
  {/if}
  <Flash state={flash} />
  {#if allowMore && hasMore()}
    <div
      class="bottom"
      use:viewport
      on:enterViewport={bottomIsInViewport}
      on:leaveViewport={bottomLeftViewport}
    />
  {/if}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .paginated-items{
    position: relative;
    min-height: 20em;
    :global(.spinner){
      margin: 1em;
    }
  }
  .bottom{
    position: absolute;
    inset-inline: 0;
    inset-block-end: min(20%, 50vh);
    z-index: 1;
    min-height: 1px;
  }
  .no-item{
    text-align: center;
    color: $grey;
    margin: 1em;
  }
</style>
