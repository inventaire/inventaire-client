<script lang="ts">
  import { pluck, uniq, pick } from 'underscore'
  import app from '#app/app'
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import { onChange } from '#app/lib/svelte/svelte'
  import { isNearby } from '#entities/components/layouts/items_lists/items_lists_helpers'
  import ItemShowModal from '#inventory/components/item_show_modal.svelte'
  import { transactionsData } from '#inventory/lib/transactions_data'
  import ItemMarker from '#map/components/item_marker.svelte'
  import LeafletMap from '#map/components/leaflet_map.svelte'
  import MapFilters from '#map/components/map_filters.svelte'
  import Marker from '#map/components/marker.svelte'
  import UserMarker from '#map/components/user_marker.svelte'
  import { i18n } from '#user/lib/i18n'
  import { user } from '#user/user_store'
  import { getDocsBounds } from './lib/map.ts'

  export let docsToDisplay = []
  export let allItems

  let allEditionsFilters, editionsFiltersData, bounds, initialBounds
  let selectedTransactionFilters = []
  let selectedEditionFilters = []
  let allTransactionFilters = []
  let transactionFiltersData = {}

  function onDocsToDisplayChange () {
    if (docsToDisplay) {
      bounds = getDocsBounds(docsToDisplay)
      const nearbyDocs = docsToDisplay.filter(item => isNearby(item.distanceFromMainUser))
      const nearbyBounds = pluck(nearbyDocs, 'position')
      initialBounds = nearbyBounds.length > 0 ? nearbyBounds : bounds
      const mainUserPosition = app.user.get('position')
      if (mainUserPosition) initialBounds = initialBounds.concat([ mainUserPosition ])
      updateFilters(docsToDisplay)
    }
  }

  const resetDocsToDisplay = () => docsToDisplay = allItems

  const updateFilters = items => {
    allEditionsFilters = []

    if (isNonEmptyArray(items)) {
      allEditionsFilters = uniq(pluck(items, 'entity'))
      allTransactionFilters = uniq(pluck(items, 'transaction'))
      editionsFiltersData = items.reduce((filtersData, item) => ({ ...filtersData, [item.entity]: item }), {})
    }
    transactionFiltersData = pick(transactionsData, allTransactionFilters)
    selectedEditionFilters = allEditionsFilters
    selectedTransactionFilters = allTransactionFilters
  }

  function isFilterSelected (item) {
    if (!item.position) return false
    if (!selectedEditionFilters.includes(item.entity)) return false
    if (!selectedTransactionFilters.includes(item.transaction)) return false
    return true
  }

  let displayedItems
  function onFiltersChange () {
    displayedItems = docsToDisplay.filter(isFilterSelected)
  }

  function findMainUserItems (displayedItems) {
    return displayedItems.find(item => item.owner === $user._id)
  }

  $: onChange(docsToDisplay, onDocsToDisplayChange)
  $: onChange(selectedEditionFilters, selectedTransactionFilters, onFiltersChange)
  $: notAllDocsAreDisplayed = displayedItems.length !== allItems.length
  $: isMainUserItemsDisplayed = findMainUserItems(displayedItems)
  let modalItem
</script>

<div class="items-map">
  {#if bounds.length > 0}
    <LeafletMap
      bounds={$user.position ? bounds.concat([ $user.position ]) : bounds}
      cluster={true}
    >
      {#each displayedItems as item (item._id)}
        <Marker latLng={item.position}>
          <ItemMarker {item} on:showItem={() => modalItem = item} />
        </Marker>
      {/each}
      {#if $user?.position && !isMainUserItemsDisplayed}
        <Marker latLng={$user.position} standalone={true}>
          <UserMarker doc={$user} />
        </Marker>
      {/if}
    </LeafletMap>
  {/if}
</div>
{#if allTransactionFilters?.length > 1}
  <MapFilters
    type="transaction"
    bind:selectedFilters={selectedTransactionFilters}
    filtersData={transactionFiltersData}
    bind:allFilters={allTransactionFilters}
    translatableFilterValues={true}
  />
{/if}
{#if allEditionsFilters?.length > 1}
  <MapFilters
    type="editions"
    bind:selectedFilters={selectedEditionFilters}
    filtersData={editionsFiltersData}
    bind:allFilters={allEditionsFilters}
  />
{/if}
{#if notAllDocsAreDisplayed}
  <div class="show-all-wrapper">
    <button class="show-all-button" on:click={resetDocsToDisplay}>
      {i18n('Show every books on map')}
    </button>
  </div>
{/if}

{#if modalItem}
  <ItemShowModal item={modalItem} showItemModal={modalItem != null} />
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .items-map{
    position: relative;
    height: 30em;
    width: 100%;
  }
  .show-all-wrapper{
    @include display-flex(column, flex-end);
    margin-block-end: 1em;
  }
  .show-all-button{
    @include tiny-button($light-grey);
    @include text-hover(#333);
    margin: 0.2em;
    padding: 0.5em;
  }
</style>
