<script context="module" lang="ts">
  type KeepScrolling = () => Promise<boolean>
</script>
<script lang="ts">
  import { assertBoolean } from '#app/lib/assert_types'
  import viewport from '#app/lib/components/actions/viewport'
  import { wait } from '#app/lib/promises'
  import Spinner from '#components/spinner.svelte'

  export let keepScrolling: KeepScrolling
  export let showSpinner = false

  let bottomElInView = false
  let fetching = false
  let loadingMore

  async function bottomIsInViewport () {
    bottomElInView = true
    if (fetching) return
    fetching = true
    loadingMore = keepScrolling()
    // Error handling should be done within keepScrolling
    const canLoadMore = await loadingMore
    fetching = false
    assertBoolean(canLoadMore)
    if (canLoadMore) {
      // Let the time to fetched content to render
      await wait(500)
      // But if the bottom is still in viewport
      // when the new content rendered, fetch more
      if (bottomElInView) bottomIsInViewport()
    }
  }

  function bottomLeftViewport () {
    bottomElInView = false
  }
</script>

<div class="infinite-scroll-wrapper">
  <slot />
  <div
    class="bottom"
    use:viewport
    on:enterViewport={bottomIsInViewport}
    on:leaveViewport={bottomLeftViewport}
  ></div>
  {#if showSpinner}
    {#await loadingMore}
      <Spinner center={true} />
    {/await}
  {/if}
</div>

<style lang="scss">
  @use "#general/scss/utils";
  .infinite-scroll-wrapper{
    position: relative;
  }
  .bottom{
    position: absolute;
    inset-inline: 0;
    inset-block-end: min(20%, 50vh);
    z-index: 1;
    min-height: 1px;
  }
</style>
