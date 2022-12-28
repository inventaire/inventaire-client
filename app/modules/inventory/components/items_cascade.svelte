<script>
  import Masonry from 'svelte-bricks'
  import ItemCard from '#inventory/components/item_card.svelte'
  import { debounce } from 'underscore'
  import Spinner from '#components/spinner.svelte'

  export let items
  export let showDistance = false
  export let waiting

  const baseColumnWidth = 230
  const gap = 16
  // Disabling animations as it sometimes fails to re-position item cards when the screen is resized
  const animate = false

  let minColWidth, maxColWidth
  function refreshColumnWidth () {
    if (window.visualViewport.width < (2 * baseColumnWidth + gap)) {
      minColWidth = Math.min(window.visualViewport.width, baseColumnWidth)
      maxColWidth = Math.min(window.visualViewport.width - gap, baseColumnWidth * 1.5)
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
    <ItemCard {item} {showDistance} />
  </Masonry>

  {#await waiting}<Spinner center={true} />{/await}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .items-cascade{
    margin: 1em 0;
  }
</style>
