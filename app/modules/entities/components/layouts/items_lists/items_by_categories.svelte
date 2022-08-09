<script>
  import ItemsByCategory from './items_by_category.svelte'
  import { categoriesHeaders, sortItemsByCategorieAndDistance } from './items_lists_helpers'
  import { isNonEmptyArray } from '#lib/boolean_tests'

  export let initialItems
  export let itemsOnMap
  export let initialBounds
  export let displayCover

  import { createEventDispatcher } from 'svelte'
  const dispatch = createEventDispatcher()
  let itemsByCategories = {}
  const showItemsOnMap = () => {
    itemsOnMap = itemsOnMap
    dispatch('scrollToMap')
  }

  const updateItems = () => {
    itemsByCategories = sortItemsByCategorieAndDistance(initialItems)
    if (isNonEmptyArray(itemsByCategories.nearbyPublic)) {
      initialBounds = itemsByCategories.nearbyPublic.map(_.property('position'))
    }
  }

  $: initialItems && updateItems()
</script>
<div class="items-lists">
  {#each Object.keys(categoriesHeaders) as category}
    <ItemsByCategory
      {category}
      {displayCover}
      headers={categoriesHeaders[category]}
      itemsByCategory={itemsByCategories[category]}
      bind:itemsOnMap
      on:showItemsOnMap={showItemsOnMap}
    />
  {/each}
</div>

<style>
  .items-lists{
    width: 100%;
  }
</style>
