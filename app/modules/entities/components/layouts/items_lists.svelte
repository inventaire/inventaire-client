<script>
  import Spinner from '#general/components/spinner.svelte'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { icon } from '#lib/utils'
  import ItemsMap from '#map/components/items_map.svelte'
  import { I18n } from '#user/lib/i18n'
  import ItemsByCategories from './items_lists/items_by_categories.svelte'
  import { getItemsData } from './items_lists/items_lists'

  export let editionsUris, initialItems = [], triggerScrollToMap

  let items = []
  let initialBounds
  let loading

  // showMap is falsy to be able to mount ItemsByCategories
  // to set initialBounds before mounting ItemsMap
  let showMap

  let fetchedEditionsUris = []
  const getItemsByCategories = async () => {
    // easy caching, waiting for proper svelte caching tool
    if (_.isEqual(fetchedEditionsUris, editionsUris)) return
    fetchedEditionsUris = editionsUris
    loading = true
    initialItems = await getItemsData(editionsUris)
    loading = false
    items = initialItems
  }

  let mapWrapper, windowScrollY
  const scrollToMap = () => {
    if (!showMap) { showMap = true }
    if (mapWrapper) { windowScrollY = mapWrapper.offsetTop }
  }

  $: {
    triggerScrollToMap && scrollToMap()
    triggerScrollToMap = false
  }
  $: emptyList = !isNonEmptyArray(items)
  $: editionsUris && getItemsByCategories()
  $: displayCover = editionsUris?.length > 1
</script>

<svelte:window bind:scrollY={windowScrollY} />
{#if loading}
  <div class="loading-wrapper">
    <p class="loading">{I18n('fetching available books...')} <Spinner/></p>
  </div>
{:else}
  {#if !emptyList}
    <div bind:this={mapWrapper}>
      {#if showMap}
        <div class='hide-map-wrapper'>
          <button
            on:click="{() => showMap = false}"
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
          {displayCover}
        />
      {/if}
    </div>
    <ItemsByCategories
      {initialItems}
      {displayCover}
      bind:initialBounds
      bind:itemsOnMap={items}
      on:scrollToMap={scrollToMap}
    />
  {/if}
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  @import '#entities/scss/items_lists';
  .hide-map-wrapper{
    @include display-flex(column, flex-end);
  }
  .loading-wrapper{
    @include display-flex(column, center);
  }
  .hide-map{
    padding: 0.5em;
    margin: 0;
  }
  /*Small screens*/
  @media screen and (max-width: 470px) {
    .hide-map{
      padding: 0.3em;
    }
  }
</style>
