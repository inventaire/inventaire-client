<script>
  import WorkSubEntity from '#entities/components/work_sub_entity.svelte'
  import { getAggregatedLabelsAndAliases } from './lib/deduplicate_helpers.js'
  import { createEventDispatcher } from 'svelte'

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
    width: 100%;
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
  .selected-from, .selected-to{
    a, .uri, .coauthors{
      color: white !important;
    }
  }
  .selected-from{
    background-color: $soft-red;
  }
  .selected-to{
    background-color: $green-tree;
  }
  h3{
    font-size: 1.2em;
    :global(a){
      font-weight: normal;
      font-size: 1.1em;
      font-family: $serif;
      user-select: text;
      &:hover{
        text-decoration: underline;
      }
    }
  }
  h4{
    font-size: 1.1em;
  }
  .description, h3, h4{
    margin: 0;
  }
  .description{
    color: $grey;
  }
  .entity-preview{
    background-color: $light-grey;
    padding: 0.5em;
    margin: 0.5em 0;
    @include radius;
  }
  .count{
    background-color: $off-white;
    @include radius;
    text-align: center;
    padding: 0 0.3em;
    font-size: 1rem;
    margin: 0 0.5em;
  }
  .uri, .all-terms{
    cursor: text;
    user-select: text;
  }
  .all-terms{
    font-weight: normal;
    text-align: left;
    max-height: 10em;
    overflow-y: auto;
  }
  .all-terms li{
    background-color: $off-white;
    padding: 0.1em;
    margin: 0.2em 0;
  }
  .occurrences{
    color: $grey;
  }
  .coauthors a:hover{
    text-decoration: underline;
  }
  .works, .series{
    ul{
      max-height: 10em;
      overflow-y: auto;
    }
  }
  .no-image, img{
    margin-right: 0.8em;
  }
  img{
    position: sticky;
    top: 64px;
    cursor: zoom-in;
    &.zoom{
      cursor: zoom-out;
    }
  }
  .no-image, img:not(.zoom){
    width: 6em;
  }
  .info{
    flex: 1 0 0;
    text-align: left;
  }
  /* Large screens */
  @media screen and (min-width: 1800px){
    ul:not(:empty){
      flex-direction: row;
    }
  }
</style>
