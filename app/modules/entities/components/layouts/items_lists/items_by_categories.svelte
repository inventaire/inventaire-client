<script>
  import ItemsByCategory from './items_by_category.svelte'
  import { sortItemsByCategorieAndDistance } from './items_lists_helpers'
  import { isNonEmptyArray } from '#lib/boolean_tests'

  export let initialItems
  export let itemsOnMap
  export let initialBounds
  export let displayCover

  import { createEventDispatcher } from 'svelte'
  const dispatch = createEventDispatcher()
  let itemsByCategories = {}

  const categoriesHeaders = {
    personal: {
      label: 'in your inventory',
      customIcon: 'user',
      backgroundColor: '#eeeeee'
    },
    network: {
      label: "in your friends' and groups' inventories",
      customIcon: 'users',
      backgroundColor: '#f4f4f4'
    },
    nearbyPublic: {
      label: 'nearby',
      customIcon: 'dot-circle-o',
      backgroundColor: '#f8f8f8'
    },
    otherPublic: {
      label: 'elsewhere',
      customIcon: 'globe',
      backgroundColor: '#fcfcfc'
    }
  }

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
