<script>
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'

  export let selectedFilters, filtersData, type, allFilters

  allFilters = Object.keys(filtersData)

  const selectAllFilters = () => { selectedFilters = allFilters }

  // All selectedFilters values must be declared initially, otherwise reset could be incomplete
  selectAllFilters()

  $: areAllFiltersSelected = allFilters.every(f => selectedFilters.includes(f))
</script>
<div class="filters-menu">
  <div class="left-menu">
    <span class="filters-title">
      {I18n(`filter by ${type}`)}
    </span>
    <div class="filters">
      {#each allFilters as filterValue}
        <label
          class="filter"
          class:selected="{selectedFilters.includes(filterValue)}"
          id="filter-label-{filterValue}"
          for="filter-value-{filterValue}"
        >
          <span class="filter-box">
            <input
              id="filter-value-{filterValue}"
              type="checkbox"
              bind:group={selectedFilters}
              value={filterValue}
            >
            {#if filtersData[filterValue].cover}
              <img class="cover" src="{imgSrc(filtersData[filterValue].cover, 128)}" alt="{filtersData[filterValue].title}">
            {:else}
              {I18n(filterValue)}
            {/if}
          </span>
          {#if filtersData[filterValue].icon}
            <span class="filter-count">
              {@html icon(filtersData[filterValue].icon)}
            </span>
          {/if}
        </label>
      {/each}
    </div>
  </div>
  <div class="right-menu">
    <button
      class="select-all-button"
      on:click={selectAllFilters}
      disabled="{areAllFiltersSelected}"
    >
    {I18n('select all filters', { filters: type })}
    </button>
  </div>
</div>
<style lang="scss">
  @import '#general/scss/utils';
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
    @include selected-button-color(#ddd);
  }
  .filters-title{
    font-weight: bold;
    margin-right: 0.5em;
  }
  .select-all-button{
    @include tiny-button($light-grey);
    @include text-hover(#333);
    margin: 0.2em;
    padding: 0.5em;
  }
  #filter-label-giving{ @include selected-button-color($giving-color); };
  #filter-label-lending{ @include selected-button-color($lending-color); };
  #filter-label-selling{ @include selected-button-color($selling-color); };
  #filter-label-inventorying{ @include selected-button-color($inventorying-color); };
  .cover{
    padding: 0.2em;
    font-size: 0.9em;
    max-width: 5em;
    height: 64px;
  }
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
  }
</style>