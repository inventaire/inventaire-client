<script>
  import ItemsByCategorie from './items_by_categorie.svelte'
  import { sortItemsByCategorieAndDistance } from './items_lists'

  export let initialItems

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
  // Todo: add circle user position
  // app.execute('show:models:on:map', items.concat([ app.user ]))
  // Add the main user to the list to make sure the map shows their position
</script>
<div class="items-lists">
  {#each Object.keys(categoriesHeaders) as categorie}
    <ItemsByCategorie
      {categorie}
      headers={categoriesHeaders[categorie]}
      itemsByCategorie={itemsByCategories[categorie]}
    />
  {/each}
</div>

<style lang="scss">
  .items-lists{
    width: 100%;
    padding: 0 0.5em;
  }
</style>
