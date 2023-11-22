<script>
  import { onChange } from '#lib/svelte/svelte'
  import SelectDropdown from '#components/select_dropdown.svelte'
  import { getSortingOptionsByNames } from '#entities/components/lib/works_browser_helpers'
  import { I18n } from '#user/lib/i18n'
  import { waitForOptionPromise } from '#entities/components/lib/sort_entities_by'

  export let sortingType = 'work', entities, waitingForItems

  const optionsByNames = getSortingOptionsByNames(sortingType)
  const options = Object.values(optionsByNames)
  let sortingName = Object.keys(optionsByNames)?.[0]

  async function sortEntities () {
    const option = optionsByNames[sortingName]
    const { sortFunction } = option
    if (sortFunction) {
      await waitForOptionPromise(sortingName, waitingForItems, entities)
      entities = entities.sort(sortFunction)
    }
  }

  $: onChange(sortingName, sortEntities)
</script>
{#if options.length > 1}
  <div class="sort-selector">
    <SelectDropdown
      bind:value={sortingName}
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
