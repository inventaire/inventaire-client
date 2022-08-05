<script>
  import Masonry from 'svelte-bricks'
  import ItemCard from '#inventory/components/item_card.svelte'
  import { debounce } from 'underscore'

  export let items
  export let showDistance = false

  // Keep in sync with #inventory/components/item_card.svelte .item-card[max-width]
  const baseColumnWidth = 230

  let columnWidth = baseColumnWidth
  function _refreshColumnWidth () {
    if (window.visualViewport.width < (2 * baseColumnWidth + 50)) {
      columnWidth = Math.min(window.visualViewport.width, 1.5 * baseColumnWidth)
    } else {
      columnWidth = baseColumnWidth
    }
  }

  const refreshColumnWidth = debounce(_refreshColumnWidth, 200)

  refreshColumnWidth()
</script>

<svelte:window on:resize={refreshColumnWidth} />

<div class="items-cascade">
  <Masonry
    {items}
    idKey="_id"
    gap={16}
    minColWidth={columnWidth}
    maxColWidth={columnWidth}
    let:item
    >
    <ItemCard {item} {showDistance} />
  </Masonry>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .items-cascade{
    margin: 1em 0;
  }
</style>
