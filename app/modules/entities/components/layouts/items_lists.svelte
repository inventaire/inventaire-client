<script>
  import Spinner from '#general/components/spinner.svelte'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { icon } from '#lib/utils'
  import ItemsMap from '#map/components/items_map.svelte'
  import { I18n } from '#user/lib/i18n'
  import ItemsByCategories from './items_lists/items_by_categories.svelte'
  import { getItemsData } from './items_lists/items_lists'
  import { createEventDispatcher } from 'svelte'
  const dispatch = createEventDispatcher()

  export let editionsUris, initialItems = [], usersSize, showMap

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

  $: emptyList = !isNonEmptyArray(items)
  $: usersSize = _.compact(_.uniq(items.map(_.property('owner')))).length
  $: editionsUris && getItemsByCategories()
  $: displayCover = editionsUris?.length > 1
</script>

{#if loading}
  <div class="loading-wrapper">
    <p class="loading">{I18n('fetching available books...')} <Spinner/></p>
  </div>
{:else}
  {#if !emptyList}
    <div class="loading-wrapper">
      <h6 class="items-title">
        {I18n('users with these editions')}
      </h6>
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
      <ItemsMap
        docsToDisplay={items}
        initialDocs={initialItems}
        {initialBounds}
        {displayCover}
      />
    {/if}
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
  .hide-map-wrapper{
    @include display-flex(column, flex-end);
    align-self: end;
  }
  .loading-wrapper{
    display: none;
  }
  .hide-map{
    padding: 0.5em;
    margin: 0;
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
