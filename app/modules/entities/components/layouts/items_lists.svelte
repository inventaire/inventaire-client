<script>
  import { icon } from '#lib/utils'
  import ItemsMap from '#map/components/items_map.svelte'
  import { I18n } from '#user/lib/i18n'
  import ItemsByCategories from './items_lists/items_by_categories.svelte'
  import { getItemsData } from './items_lists/items_lists_helpers'
  import { createEventDispatcher } from 'svelte'
  import { BubbleUpComponentEvent } from '#lib/svelte/svelte'

  const dispatch = createEventDispatcher()
  const bubbleUpComponentEvent = BubbleUpComponentEvent(dispatch)

  export let editionsUris, initialItems = [], itemsUsers, showMap, itemsByEditions, mapWrapperEl, itemsListsWrapperEl

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

  $: itemsUsers = _.compact(_.uniq(items.map(_.property('owner'))))
  $: itemsByEditions = _.groupBy(initialItems, 'entity')
  $: editionsUris && getItemsByCategories()
  $: displayCover = editionsUris?.length > 1
</script>

<div class="items-lists-wrapper" bind:this={itemsListsWrapperEl}>
  <ItemsByCategories
    {initialItems}
    {displayCover}
    {waitingForItems}
    bind:initialBounds
    bind:itemsOnMap={items}
    on:showMapAndScrollToMap={bubbleUpComponentEvent}
  />
</div>

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
  <div class="map-wrapper" bind:this={mapWrapperEl}>
    <ItemsMap
      docsToDisplay={items}
      initialDocs={initialItems}
      {initialBounds}
    />
  </div>
{/if}

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
  .map-wrapper, .items-lists-wrapper{
    align-self: stretch;
  }
  .map-wrapper{
    // Set to the .simple-map height to allow to scroll to the right level
    // before the map is rendered
    min-height: 30em;
  }
  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .hide-map{
      padding: 0.3em;
    }
  }
</style>
