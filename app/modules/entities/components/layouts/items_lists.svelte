<script>
  import { I18n } from '#user/lib/i18n'
  import Spinner from '#general/components/spinner.svelte'
  import { icon } from '#lib/utils'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { getItemsData } from './items_lists/items_lists'
  import ItemsByCategories from './items_lists/items_by_categories.svelte'
  import ItemsMap from '#map/components/items_map.svelte'

  export let uri

  let items = []
  let initialItems = []
  let initialBounds

  // Mount ItemsByCategories with initialBounds
  // before mounting ItemsMap
  let showMap

  const getItemsByCategories = async () => {
    let uris
    if (uri) uris = [ uri ]
    initialItems = await getItemsData(uris)
    items = initialItems
  }

  let mapWrapper, windowScrollY
  const scrollToMap = e => {
    if (!showMap) { showMap = true }
    if (mapWrapper) { windowScrollY = mapWrapper.offsetTop }
  }

  $: emptyList = !isNonEmptyArray(items)
</script>

<svelte:window bind:scrollY={windowScrollY} />
{#await getItemsByCategories()}
  <div class="loading-wrapper">
    <p class="loading">{I18n('fetching available books...')} <Spinner/></p>
  </div>
{:then}
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
        />
      {/if}
    </div>
    <ItemsByCategories
      {initialItems}
      bind:initialBounds
      bind:itemsOnMap={items}
      on:scrollToMap={scrollToMap}
    />
  {/if}
{/await}

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
