<script>
  import Flash from '#lib/components/flash.svelte'
  import viewport from '#lib/components/actions/viewport'
  import { wait } from '#lib/promises'
  import { onChange } from '#lib/svelte/svelte'
  import assert_ from '#lib/assert_types'
  import { debounce } from 'underscore'
  import { i18n } from '#user/lib/i18n'

  export let Component, componentProps, pagination

  let items = [], flash, waiting
  let fetchMore, hasMore, allowMore

  function fetch () {
    waiting = fetchMore()
      .then(() => {
        assert_.array(pagination.items)
        items = pagination.items
      })
      .catch(err => flash = err)
  }

  let bottomElInView = false
  async function bottomIsInViewport () {
    bottomElInView = true
    if (!(allowMore && hasMore())) return
    await fetch()
    // Let the time to fetched items to render
    await wait(100)
    // But if the bottom is still in viewport
    // when the new items are rendered, fetch more
    if (bottomElInView) bottomIsInViewport()
  }

  const lazyBottomIsInViewport = debounce(bottomIsInViewport, 200)

  function bottomLeftViewport () {
    bottomElInView = false
  }

  let firstCall = true
  function reinitializePagination () {
    if (!pagination) return
    ;({ fetchMore, hasMore, allowMore } = pagination)
    if ((allowMore || firstCall) && hasMore()) {
      firstCall = false
      fetch()
    } else {
      items = pagination.items
    }
  }

  $: onChange(pagination, reinitializePagination)
</script>

<div class="paginated-items">
  {#if items?.length > 0}
    <svelte:component this={Component} {items} {waiting} {...componentProps} />
  {:else}
    <p class="no-item">{i18n('There is nothing here')}</p>
  {/if}
  <Flash state={flash} />
  <div class="bottom"
    use:viewport
    on:enterViewport={lazyBottomIsInViewport}
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
  .no-item{
    text-align: center;
    color: $grey;
    margin: 1em;
  }
</style>
