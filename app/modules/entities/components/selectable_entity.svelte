<script>
  import { createEventDispatcher } from 'svelte'
  import WorkSubEntity from '#entities/components/work_sub_entity.svelte'
  import { getAggregatedLabelsAndAliases } from './lib/deduplicate_helpers.ts'

  export let entity, from, to, filterPattern

  const dispatch = createEventDispatcher()

  const aggregatedLabelsAndAliases = getAggregatedLabelsAndAliases(entity)
</script>

<button
  on:click={() => dispatch('select', entity)}
  class:selected-from={from?.uri === entity.uri}
  class:selected-to={to?.uri === entity.uri}
>
  <WorkSubEntity
    {entity}
    {filterPattern}
    {aggregatedLabelsAndAliases}
  />
</button>

<style lang="scss">
  @import "#general/scss/utils";

  button{
    background-color: white;
    @include radius;
    inline-size: 100%;
    padding: 0.5em;
    transition: background-color 0.2s ease;
    display: flex;
    flex-direction: row;
    align-items: flex-start;
    justify-content: center;
  }

  button:hover{
    opacity: 0.95;
  }
  .selected-from{
    background-color: $soft-red;
  }
  .selected-to{
    background-color: $green-tree;
  }
</style>
