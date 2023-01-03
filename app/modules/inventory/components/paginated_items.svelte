<script>
  import Flash from '#lib/components/flash.svelte'
  import viewport from '#lib/components/actions/viewport'
  import { wait } from '#lib/promises'
  import { onChange } from '#lib/svelte/svelte'
  import assert_ from '#lib/assert_types'
  import { i18n } from '#user/lib/i18n'

  export let Component, componentProps, pagination, haveSeveralOwners = false

  let items = [], flash, waiting
  let fetchMore, hasMore, allowMore

  let fetching = false
  async function fetch () {
    if (fetching) return
    fetching = true
    waiting = fetchMore()
      .then(() => {
        assert_.array(pagination.items)
        items = pagination.items
      })
      .catch(err => flash = err)
      .finally(() => fetching = false)
  }

  let bottomElInView = false
  async function bottomIsInViewport () {
    bottomElInView = true
    if (!(allowMore && hasMore())) return
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
      fetch()
    }
  }

  $: onChange(pagination, reinitializePagination)
</script>

<div class="paginated-items">
  {#if items?.length > 0}
    <svelte:component
      this={Component}
      {items}
      {waiting}
      {haveSeveralOwners}
      {...componentProps} />
  {:else}
    <p class="no-item">{i18n('There is nothing here')}</p>
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
  @import '#general/scss/utils';
  .paginated-items{
    position: relative;
    min-height: 20em;
  }
  .bottom{
    position: absolute;
    left: 0;
    right: 0;
    bottom: min(20%, 50vh);
    z-index: 1;
    min-height: 1px;
  }
  .no-item{
    text-align: center;
    color: $grey;
    margin: 1em;
  }
</style>
