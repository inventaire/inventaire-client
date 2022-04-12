<script>
  import ItemsByCategorie from './items_by_categorie.svelte'
  import { sortItemsByCategorieAndDistance } from './items_lists'

  export let initialItems
  export let itemsOnMap

  import { createEventDispatcher } from 'svelte'
  const dispatch = createEventDispatcher()

  let itemsByCategories = sortItemsByCategorieAndDistance(initialItems)

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

  $: nearbyPublicItems = itemsByCategories.nearbyPublic

  // Todo: add circle user position
  // Add the main user to the list to make sure the map shows their position
</script>
<div class="items-lists">
  {#each Object.keys(categoriesHeaders) as categorie}
    <ItemsByCategorie
      {categorie}
      headers={categoriesHeaders[categorie]}
      itemsByCategorie={itemsByCategories[categorie]}
      bind:itemsOnMap
      on:showItemsOnMap={showItemsOnMap}
    />
  {/each}
</div>

<style lang="scss">
  .items-lists{
    width: 100%;
    padding: 0 0.5em;
  }
</style>
