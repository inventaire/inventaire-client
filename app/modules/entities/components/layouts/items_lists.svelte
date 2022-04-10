<script>
  import map_ from '#map/lib/map'
  import { I18n } from '#user/lib/i18n'
  import Spinner from '#general/components/spinner.svelte'
  import Modal from '#general/components/modal.svelte'
  import { icon } from '#lib/utils'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { getItemsData } from './items_lists/items_lists'
  import ItemsByCategories from './items_lists/items_by_categories.svelte'
  import ItemsMap from '#map/components/items_map.svelte'

  export let uri

  let items = []
  let initialItems = []
  let boundsDocs = []
  let showMap = false

  const getItemsByCategories = async () => {
    initialItems = await getItemsData(uri)
    items = initialItems
  }

  const showMapByItemsCategorie = items => {
    // do not display map when items is first set
    if (isNonEmptyArray(items) && (initialItems !== items)) {
      showMap = true
    }
  }

  const getLeafletPromise = async () => map_.getLeaflet()

  const hideMap = () => showMap = false

  $: {
    showMapByItemsCategorie(items)
  }
  $: emptyList = !isNonEmptyArray(items)
  $: {
    if (boundsDocs.length === 1) {
      showMap = true
    }
  }
</script>

{#await getItemsByCategories()}
  <div class="loading-wrapper">
    <p class="loading">{I18n('fetching available books...')} <Spinner/></p>
  </div>
{:then}
  <ItemsByCategories
    bind:mapBoundsDocs={boundsDocs}
    {initialItems}
    bind:itemsOnMap={items}
  />
  {#if showMap}
    <Modal on:close={hideMap}>
      {#await getLeafletPromise()}
        <div class="loading-wrapper">
          <p class="loading">{I18n('loading map...')} <Spinner/></p>
        </div>
      {:then}
        <ItemsMap
          type="item"
          docsToDisplay={items}
          initialDocs={initialItems}
          {boundsDocs}
        />
      {/await}
    </Modal>
  {/if}
  {#if !showMap && Object.keys(items).length > 0}
    <div class='show-map-wrapper'>
      <button
        on:click="{() => showMap = true}"
        class="show-map"
      >
        {I18n('show map')}
        {@html icon('map')}
      </button>
    </div>
  {/if}
{/await}

<style lang="scss">
  @import '#general/scss/utils';
  @import '#entities/scss/items_lists';
  .hide-map-wrapper, .reset-all-wrapper{
    @include display-flex(column, flex-end);
  }
  .show-map-wrapper{
    @include display-flex(column, center);
  }
  .loading-wrapper{
    @include display-flex(column, center);
  }
  .show-map{
    @include selected-button-color($grey);
    padding: 0.5em;
  }
  .hide-map{
    font-size: 1.3rem;
    margin-bottom: 1em;
  }
  .show-all-button{
    margin: 0.5em 0;
  }
  /*Small screens*/
  @media screen and (max-width: 470px) {
    .hide-map{
      padding: 0.3em;
    }
  }
</style>
