<script>
  import Flash from '#lib/components/flash.svelte'
  import viewport from '#lib/components/actions/viewport'
  import { wait } from '#lib/promises'
  import { onChange } from '#lib/svelte/svelte'
  import { clone } from 'underscore'

  export let Component, itemsIds, componentProps

  const allowMore = true

  let items = [], flash, waiting

  let hasMore, fetchMore
  async function setupPagination () {
    items = []
    const remainingItems = clone(itemsIds)
    hasMore = () => remainingItems.length > 0
    fetchMore = async () => {
      const batch = remainingItems.splice(0, 20)
      if (batch.length === 0) return
      await app.request('items:getByIds', { ids: batch, items })
      items = items
    }
    fetch()
  }

  function fetch () {
    waiting = fetchMore()
      .catch(err => flash = err)
  }

  $: onChange(itemsIds, setupPagination)

  let bottomElInView = false
  async function bottomIsInViewport () {
    bottomElInView = true
    if (allowMore && hasMore()) {
      await fetch()
      // Let the time to fetched items to render
      await wait(100)
      // But if the bottom is still in viewport
      // when the new items are rendered, fetch more
      if (bottomElInView) bottomIsInViewport()
    }
  }

  function bottomLeftViewport () {
    bottomElInView = false
  }
</script>

<div class="paginated-items">
  <svelte:component this={Component} {items} {waiting} {...componentProps} />
  <Flash state={flash} />
  <div class="bottom"
    use:viewport
    on:enterViewport={bottomIsInViewport}
    on:leaveViewport={bottomLeftViewport}
    ></div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .paginated-items{
    position: relative;
    min-height: 20em;
  }
  .bottom{
    position: absolute;
    left: 0;
    right: 0;
    bottom: min(60%, 100vh);
    z-index: 1;
    min-height: 1px;
  }
</style>
