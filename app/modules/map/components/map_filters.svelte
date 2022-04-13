<script>
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'

  export let selectedFilters, data, allFilters

  const { filtersTitle, filtersData } = data

  const selectAllFilters = () => { selectedFilters = allFilters }

  $: areAllFiltersSelected = allFilters.every(f => selectedFilters.includes(f))
</script>
<div class="filters-menu">
  <div class="left-menu">
    <span class="filters-title">
      {I18n(`filter by ${filtersTitle}`)}
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
            {I18n(filterValue)}
          </span>
          <span class="filter-count">
            {@html icon(filtersData[filterValue].icon)}
          </span>
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
    {I18n('select all filters', { filtersTitle })}
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
    margin: 0 0.5em;
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
