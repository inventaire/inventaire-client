<script>
  import { icon } from '#lib/utils'
  import ItemsMap from '#map/components/items_map.svelte'
  import { I18n } from '#user/lib/i18n'
  import ItemsByCategories from './items_lists/items_by_categories.svelte'
  import { getItemsData } from './items_lists/items_lists_helpers'
  import { createEventDispatcher } from 'svelte'
  const dispatch = createEventDispatcher()

  export let editionsUris, initialItems = [], itemsUsers, showMap, itemsByEditions

  let items = []
  let initialBounds
  let waitingForItems

  // showMap is falsy to be able to mount ItemsByCategories
  // to set initialBounds before mounting ItemsMap
  showMap = false

  let fetchedEditionsUris = []
  const getItemsByCategories = async () => {
    // easy caching, waiting for proper svelte caching tool
    if (_.isEqual(fetchedEditionsUris, editionsUris)) return
    fetchedEditionsUris = editionsUris
    waitingForItems = getItemsData(editionsUris)
    initialItems = await waitingForItems
    items = initialItems
  }

  const scrollToMap = () => {
    dispatch('scrollToItemsList')
    showMap = true
  }

  $: itemsUsers = _.compact(_.uniq(items.map(_.property('owner'))))
  $: itemsByEditions = _.groupBy(initialItems, 'entity')
  $: editionsUris && getItemsByCategories()
  $: displayCover = editionsUris?.length > 1
</script>

{#if showMap}
  <div class='hide-map-wrapper'>
    <button
      on:click={() => showMap = false}
      class="hide-map"
    >
      {I18n('hide map')}
      {@html icon('close')}
    </button>
  </div>
  <ItemsMap
    docsToDisplay={items}
    initialDocs={initialItems}
    {initialBounds}
  />
{/if}

<ItemsByCategories
  {initialItems}
  {displayCover}
  {waitingForItems}
  bind:initialBounds
  bind:itemsOnMap={items}
  on:scrollToMap={scrollToMap}
/>

<style lang="scss">
  @import '#general/scss/utils';
  .hide-map-wrapper{
    @include display-flex(column, flex-end);
    align-self: end;
  }
  .hide-map{
    padding: 0.5em;
    margin: 0;
  }

  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .hide-map{
      padding: 0.3em;
    }
  }
</style>
