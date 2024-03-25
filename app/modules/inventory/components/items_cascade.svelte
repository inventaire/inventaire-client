<script>
  import Masonry from 'svelte-bricks'
  import { debounce } from 'underscore'
  import Spinner from '#components/spinner.svelte'
  import ItemCard from '#inventory/components/item_card.svelte'
  import { getViewportWidth } from '#lib/screen'

  export let items
  export let showDistance = false
  export let shelfId = null
  export let waiting

  const baseColumnWidth = 230
  const gap = 16
  // Disabling animations as it sometimes fails to re-position item cards when the screen is resized
  const animate = false

  let minColWidth, maxColWidth
  function refreshColumnWidth () {
    const viewportWidth = getViewportWidth()
    if (viewportWidth < (2 * baseColumnWidth + gap)) {
      minColWidth = Math.min(viewportWidth, baseColumnWidth)
      maxColWidth = Math.min(viewportWidth - gap, baseColumnWidth * 1.5)
    } else {
      minColWidth = maxColWidth = baseColumnWidth
    }
  }
  refreshColumnWidth()
  const lazyRefreshColumnWidth = debounce(refreshColumnWidth, 200)
</script>

<svelte:window on:resize={lazyRefreshColumnWidth} />

<div class="items-cascade">
  <Masonry
    {items}
    idKey="_id"
    {gap}
    {minColWidth}
    {maxColWidth}
    {animate}
    let:item
  >
    <ItemCard {item} {showDistance} {shelfId} />
  </Masonry>

  {#await waiting}<Spinner center={true} />{/await}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .items-cascade{
    margin: 1em 0;
  }
</style>
