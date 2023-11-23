<script>
  import { onChange } from '#lib/svelte/svelte'
  import SelectDropdown from '#components/select_dropdown.svelte'
  import { getSortingOptionsByName } from '#entities/components/lib/works_browser_helpers'
  import { I18n } from '#user/lib/i18n'
  import { sortEntities } from '#entities/components/lib/sort_entities_by'

  export let sortingType = 'work', entities, waitingForItems

  const optionsByName = getSortingOptionsByName(sortingType)
  const options = Object.values(optionsByName)
  let sortingName = Object.keys(optionsByName)?.[0]

  $: option = optionsByName[sortingName]
  async function sortEntitiesBy () {
    entities = await sortEntities({
      sortingType,
      option,
      entities,
      waitingForItems
    })
  }
  $: onChange(sortingName, sortEntitiesBy)
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
