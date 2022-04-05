<script>
  import map_ from '#map/lib/map'
  import Spinner from '#general/components/spinner.svelte'
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import SimpleMap from '#map/components/simple_map.svelte'
  import { markersConfigByTypes, getBounds } from './lib/map'

  const markerOptions = markersConfigByTypes.item

  export let initialDocs
  export let docsToDisplay = []
  let idsToDisplay = []

  import { transactionsData } from '#inventory/lib/transactions_data'
  const filtersTitle = 'transaction'
  const allFilters = Object.keys(transactionsData)
  const getFiltersValues = doc => [ doc.transaction ]

  let selectedFilters = allFilters

  const aggregateFilters = (filters, filterName) => {
    filters[filterName] = new Set()
    return filters
  }
  let idsByFilters = selectedFilters.reduce(aggregateFilters, {})

  const assignIdsByFilter = doc => {
    const docFilterValue = doc[filtersTitle]
    const idsFilter = idsByFilters[docFilterValue]
    idsFilter.add(doc.id)
  }
  initialDocs.forEach(assignIdsByFilter)

  const selectAllFilters = () => selectedFilters = allFilters

  let bounds
  const syncDocValues = () => {
    bounds = getBounds(docsToDisplay)
    idsToDisplay = docsToDisplay.map(_.property('id'))
  }

  const resetDocsToDisplay = () => docsToDisplay = initialDocs

  $: notAllDocsAreDisplayed = docsToDisplay.length !== initialDocs.length
  $: docsToDisplay && syncDocValues()
</script>
{#await map_.getLeaflet()}
  <div class="loading-wrapper">
    <p class="loading">{I18n('loading map...')} <Spinner/></p>
  </div>
{:then}
  <div class="items-map">
    <SimpleMap
      {markerOptions}
      {bounds}
      {initialDocs}
      bind:selectedFilters
      {idsToDisplay}
      {getFiltersValues}
    />
    <div class="filters-menu">
      <div class="left-menu">
        <span class="filters-title">
          {I18n('filter by transaction')}
        </span>
        <div class="filters">
          {#each allFilters as filterName}
            <label
              class="filter"
              class:selected="{selectedFilters.includes(filterName)}"
              id="filter-label-{filterName}"
              for="filter-value-{filterName}"
            >
              <span class="filter-box">
                <input
                  id="filter-value-{filterName}"
                  type="checkbox"
                  bind:group={selectedFilters}
                  value={filterName}
                >
                {I18n(filterName)}
              </span>
              <span class="filter-count">
                {@html icon(transactionsData[filterName].icon)}
                <!-- {docsIdsByFilters[filterName]?.length || 0} -->
              </span>
            </label>
          {/each}
        </div>
      </div>
      <div class="right-menu">
        <button
          class="select-all-button"
          on:click={selectAllFilters}
          disabled="{selectedFilters === allFilters}"
        >
        {I18n('select all filters', { filtersTitle })}
        </button>
      </div>
    </div>
  </div>
  {#if notAllDocsAreDisplayed}
    <div class='show-all-wrapper'>
      <button class="show-all-button" on:click={resetDocsToDisplay}>
        {I18n('show every books on map')}
      </button>
    </div>
  {/if}
{/await}
<style lang="scss">
  @import '#general/scss/utils';
  @import '#map/scss/objects_markers';
  .show-all-wrapper{
    @include display-flex(column, flex-end);
    margin-bottom: 1em;
  }
  .loading-wrapper{
    @include display-flex(column, center);
  }
  .filters-menu{
    @include display-flex(row, center, space-between);
    padding: 0.5em;
    padding-left: 1em;
    background-color: $off-white;
  }
  .left-menu{
    @include display-flex(row, center, flex-start);
  }
  .filters{
    @include display-flex(row, center,flex-start,wrap);
  }
  .filter{
    padding: 0.5em;
    margin: 0 0.5em;
  }
  .filters-title{
    font-weight: bold;
    margin-right: 0.5em;
  }
  .select-all-button, .show-all-button{
    @include tiny-button($light-grey);
    @include text-hover(#333);
    margin: 0.2em;
    padding: 0.5em;
  }
  #filter-label-giving{ @include selected-button-color($giving-color); };
  #filter-label-lending{ @include selected-button-color($lending-color); };
  #filter-label-selling{ @include selected-button-color($selling-color); };
  #filter-label-inventorying{ @include selected-button-color($inventorying-color); };
  :disabled{
    cursor: not-allowed;
    opacity: 0.5;
  }
  /*Small screens*/
  @media screen and (max-width: 470px) {
    .filters-menu{
      @include display-flex(column,flex-start);
      padding-left: 1em;
    }
    .left-menu{
      @include display-flex(column, center, flex-start);
    }
    .filters{
      @include display-flex(row, center,center,wrap);
    }
    .large-screen{
      display: none;
    }
  }
</style>
