<script>
  import Flash from '#lib/components/flash.svelte'
  import viewport from '#lib/components/actions/viewport'
  import { wait } from '#lib/promises'
  import { onChange } from '#lib/svelte/svelte'

  export let Component, componentProps, pagination

  let items = [], flash, waiting

  function fetch () {
    waiting = fetchMore()
      .then(() => items = pagination.items)
      .catch(err => flash = err)
  }

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

  let fetchMore, hasMore, allowMore
  function reinitializePagination () {
    if (!pagination) return
    ;({ fetchMore, hasMore, allowMore } = pagination)
    fetch()
  }

  $: onChange(pagination, reinitializePagination)
</script>

<div class="paginated-items">
  {#if items?.length > 0 || true}
    <svelte:component this={Component} {items} {waiting} {...componentProps} />
  {/if}
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
