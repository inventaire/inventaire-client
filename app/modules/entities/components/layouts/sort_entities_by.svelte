<script lang="ts">
  import SelectDropdown from '#components/select_dropdown.svelte'
  import { sortEntities } from '#entities/components/lib/sort_entities_by'
  import { getSortingOptionsByName } from '#entities/components/lib/works_browser_helpers'
  import { icon } from '#lib/handlebars_helpers/icons'
  import { onChange } from '#lib/svelte/svelte'
  import { i18n } from '#user/lib/i18n'

  export let sortingType = 'work', entities, waitingForItems

  const optionsByName = getSortingOptionsByName(sortingType) || {}
  let options, sortingName

  if (optionsByName) {
    options = Object.values(optionsByName)
    sortingName = Object.keys(optionsByName)?.[0]
  }

  let initialSorting = true

  $: option = optionsByName[sortingName]
  async function sortEntitiesBy () {
    if (initialSorting) { return initialSorting = false }
    entities = await sortEntities({
      option,
      entities,
      promise: waitingForItems,
    })
  }

  function reverseOrder () {
    entities = entities.reverse()
  }

  $: onChange(sortingName, sortEntitiesBy)
</script>
{#if options.length > 1}
  <div class="sort-selector">
    <SelectDropdown
      bind:value={sortingName}
      {options}
      buttonLabel={i18n('Sort by')}
      on:selectSameOption={reverseOrder}
    >
      <div slot="selected-option-line-end">
        {@html icon('exchange')}
      </div>
    </SelectDropdown>
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
      min-width: 11em;
    }
    :global(.inner-select-option){
      line-height: 1em;
    }
  }
  [slot="selected-option-line-end"]{
    :global(.fa-exchange){
      transform: rotate(90deg);
      margin-inline-end: 0;
      opacity: 0.8;
      line-height: 1rem;
    }
  }
</style>
