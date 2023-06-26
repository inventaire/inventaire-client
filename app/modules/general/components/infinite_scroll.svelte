<script>
  import assert_ from '#lib/assert_types'
  import viewport from '#lib/components/actions/viewport'
  import { wait } from '#lib/promises'

  export let keepScrolling

  assert_.function(keepScrolling)

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
    assert_.boolean(canLoadMore)
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
  />
</div>

<style lang="scss">
  @import "#general/scss/utils";
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
