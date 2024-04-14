<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { difference, groupBy } from 'underscore'
  import { icon } from '#lib/icons'
  import { BubbleUpComponentEvent } from '#lib/svelte/svelte'
  import ItemsMap from '#map/components/items_map.svelte'
  import type { EntityUri } from '#server/types/entity.ts'
  import type { Item } from '#server/types/item.ts'
  import { i18n } from '#user/lib/i18n'
  import ItemsByCategories from './items_lists/items_by_categories.svelte'
  import { getItemsData } from './items_lists/items_lists_helpers.ts'

  const dispatch = createEventDispatcher()
  const bubbleUpComponentEvent = BubbleUpComponentEvent(dispatch)

  export let editionsUris: EntityUri[]
  export let mapWrapperEl
  export let itemsListsWrapperEl
  // showMap is false to be able to mount ItemsByCategories
  // to set initialBounds before mounting ItemsMap
  export let showMap = false

  export let itemsByEditions: Record<EntityUri, Item[]> = null
  export let waitingForItems = null
  export let allItems: Item[] = null

  let itemsOnMap

  let fetchedEditionsUris = []
  const getItemsByCategories = async () => {
    const newUris = difference(editionsUris, fetchedEditionsUris)
    if (newUris.length === 0) return
    fetchedEditionsUris = [ ...editionsUris, ...newUris ]
    waitingForItems = getItemsData(newUris)
    allItems = await waitingForItems
    itemsOnMap = allItems
  }

  $: itemsByEditions = groupBy(allItems, 'entity')
  $: if (editionsUris) getItemsByCategories()
  $: displayCover = editionsUris?.length > 1
</script>

<div class="items-lists-wrapper" bind:this={itemsListsWrapperEl}>
  <ItemsByCategories
    {allItems}
    {displayCover}
    {waitingForItems}
    bind:itemsOnMap
    on:showMapAndScrollToMap={bubbleUpComponentEvent}
  />
</div>

{#if showMap}
  <div class="map-wrapper" bind:this={mapWrapperEl}>
    <ItemsMap
      {allItems}
      docsToDisplay={itemsOnMap}
    />
    <button
      on:click={() => showMap = false}
      class="close-map-button"
      title={i18n('Close map')}
    >
      {@html icon('close')}
    </button>
  </div>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .map-wrapper, .items-lists-wrapper{
    align-self: stretch;
  }
  .map-wrapper{
    // Set to the .simple-map height to allow to scroll to the right level
    // before the map is rendered
    padding: 0.5em;
    min-block-size: 30em;
    position: relative;
    background-color: $off-white;
  }
  .close-map-button{
    @include position(absolute, 1rem, 1rem);
    // Above .leaflet-pane
    z-index: 401;
    padding: 0.2rem;
    margin: 0;
    font-size: 1.2rem;
    @include bg-hover(white);
    @include radius;
  }
  /* Small screens */
  @media screen and (max-width: $small-screen){
    .close-map-button{
      padding: 0.3em;
    }
  }
</style>
