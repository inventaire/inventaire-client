<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/icons'
  import { imgSrc } from '#lib/handlebars_helpers/images'

  export let selectedFilters, filtersData, type, allFilters
  export let translatableFilterValues = false

  allFilters = Object.keys(filtersData)

  const selectAllFilters = () => { selectedFilters = allFilters }

  const unselectAllFilters = () => { selectedFilters = [] }

  // All selectedFilters values must be declared initially, otherwise reset could be incomplete
  selectAllFilters()

  $: areAllFiltersSelected = allFilters.every(f => selectedFilters.includes(f))
</script>
<div class="filters-title">
  {i18n(`Filter by ${type}`)}
</div>
<div class="filters-menu">
  <div class="left-menu">
    <div class="filters">
      {#each allFilters as filterValue}
        <label
          class="filter"
          class:selected={selectedFilters.includes(filterValue)}
          id="filter-label-{filterValue}"
          for="filter-value-{filterValue}"
        >
          <input
            id="filter-value-{filterValue}"
            type="checkbox"
            bind:group={selectedFilters}
            value={filterValue}
          />
          {#if filtersData[filterValue].image}
            <img
              class="cover"
              src={imgSrc(filtersData[filterValue].image, 128)}
              alt={filtersData[filterValue].title}
            />
          {:else}
            <div class="no-cover-data">
              {#if filtersData[filterValue].title}
                {filtersData[filterValue].title}
              {/if}
              <div class="filter-value">
                {translatableFilterValues ? I18n(filterValue) : filterValue}
              </div>
            </div>
          {/if}
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
    {#if areAllFiltersSelected}
      <button
        class="select-filters"
        on:click={unselectAllFilters}
      >
        {i18n('Unselect all filters')}
      </button>
    {:else}
      <button
        class="select-filters"
        on:click={selectAllFilters}
      >
        {i18n('Select all filters')}
      </button>
    {/if}
  </div>
</div>
<style lang="scss">
  @import "#general/scss/utils";
  @mixin filter-button($color, $text-color:white){
    color: $dark-grey;
    background-color: white;
    border-color: $color;
    margin: 0.2em;
    border: 2px solid $light-grey;
    border-radius: 5px;
    @include sans-serif;
    font-weight: normal;
    &:hover{
      background-color: $off-white;
      border-color: $color;
    }
  }
  .filters-menu{
    @include display-flex(row, center, space-between);
    padding: 0.5em;
    background-color: white;
  }
  .left-menu{
    @include display-flex(row, center, flex-start);
  }
  .filters{
    @include display-flex(row, center,flex-start,wrap);
  }
  .filter{
    @include display-flex(row, center);
    @include filter-button(#ddd);
    padding: 0.5em;
  }
  .filters-title{
    color: $grey;
    background-color: white;
    padding-block-start: 0.5em;
    padding-inline-start: 1em;
    margin-block-start: 0.5em;
  }
  .select-filters{
    @include tiny-button($off-white, black);
    margin: 0.2em;
    padding: 0.5em;
  }
  #filter-label-giving{ @include filter-button($giving-color); }
  #filter-label-lending{ @include filter-button($lending-color); }
  #filter-label-selling{ @include filter-button($selling-color); }
  #filter-label-inventorying{ @include filter-button($inventorying-color); }
  .cover{
    font-size: 0.9em;
    max-width: 5em;
  }
  :disabled{
    cursor: not-allowed;
    opacity: 0.5;
  }
  .no-cover-data{
    display: inline-block;
    max-width: 8em;
  }
  .filter-value{
    overflow: hidden;
  }
  /* Small screens */
  @media screen and (width < 470px){
    .filters-menu{
      @include display-flex(column, flex-start);
      padding-inline-start: 1em;
    }
    .left-menu{
      @include display-flex(column, center, flex-start);
    }
    .filters{
      @include display-flex(row, center,center,wrap);
    }
  }
</style>
