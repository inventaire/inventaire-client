<script>
  import { onChange } from '#lib/svelte/svelte'
  import SelectDropdown from '#components/select_dropdown.svelte'
  import { getSortingOptionsByNames } from '#entities/components/lib/works_browser_helpers'
  import { byPublicationDate, byPopularity, bySerieOrdinal, getAndAssignPopularity } from '#entities/lib/entities'
  import { I18n } from '#user/lib/i18n'

  export let sortingType = 'works', entities

  const optionsByNames = getSortingOptionsByNames(sortingType)
  const options = Object.values(optionsByNames)
  let currentSortingName = Object.keys(optionsByNames)?.[0]

  const sortFunctions = {
    byPublicationDate,
    byPopularity,
    bySerieOrdinal
  }

  async function sortEntities () {
    const sortFn = sortFunctions[currentSortingName]
    if (sortFn) {
      if (currentSortingName === 'byPopularity') {
        let promise = getAndAssignPopularity(entities)
        const option = optionsByNames.byPopularity
        option.promise = promise
        await promise
      }
      entities = entities.sort(sortFn)
    }
  }
  $: onChange(currentSortingName, sortEntities)
</script>
{#if options.length > 1}
  <div class="sort-selector">
    <SelectDropdown
      bind:value={currentSortingName}
      {options}
      buttonLabel={I18n('sort_by')}
    />
  </div>
{/if}
<style lang="scss">
  @import "#general/scss/utils";
  .sort-selector{
    align-self: end;
    :global(.select-dropdown){
      @include display-flex(row, center, stretch);
    }
    :global(.dropdown-content), :global(.dropdown-button){
      min-width: 10em;
    }
  }
</style>
