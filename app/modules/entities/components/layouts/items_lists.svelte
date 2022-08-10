<script>
  import Spinner from '#general/components/spinner.svelte'
  import { icon } from '#lib/utils'
  import ItemsMap from '#map/components/items_map.svelte'
  import { I18n } from '#user/lib/i18n'
  import ItemsByCategories from './items_lists/items_by_categories.svelte'
  import { getItemsData } from './items_lists/items_lists_helpers'
  import { createEventDispatcher } from 'svelte'
  const dispatch = createEventDispatcher()

  export let editionsUris, initialItems = [], usersSize, showMap, itemsByEditions

  let items = []
  let initialBounds
  let loading

  // showMap is falsy to be able to mount ItemsByCategories
  // to set initialBounds before mounting ItemsMap
  showMap = false

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

  const scrollToMap = () => {
    dispatch('scrollToItemsList')
    showMap = true
  }

  $: usersSize = _.compact(_.uniq(items.map(_.property('owner')))).length
  $: itemsByEditions = _.groupBy(initialItems, 'entity')
  $: editionsUris && getItemsByCategories()
  $: displayCover = editionsUris?.length > 1
</script>

{#if loading}
  <div class="loading-wrapper">
    <p class="loading">{I18n('fetching available books...')} <Spinner/></p>
  </div>
{:else}
  <ItemsByCategories
    {initialItems}
    {displayCover}
    bind:initialBounds
    bind:itemsOnMap={items}
    on:scrollToMap={scrollToMap}
  />
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

  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    .loading-wrapper{
      // Reduce risk and/or proportion of scroll jump when a filter triggers a reloading
      padding-bottom: 20em;
    }
  }

  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .loading-wrapper{
      @include display-flex(column, center);
    }
    .hide-map{
      padding: 0.3em;
    }
  }
</style>
