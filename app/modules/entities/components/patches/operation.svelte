<script lang="ts">
  import { loadInternalLink } from '#app/lib/utils'
  import OperationValue from './operation_value.svelte'

  export let operation
  export let showContributionFilter = false

  const { op, path, propertyLabel, value, filter, filterPathname } = operation
</script>

<li class="operation operation-{op}">
  <div class="op">{op}</div>
  <div class="path" title={path}>{propertyLabel}</div>
  <div class="value">
    <OperationValue {value} />
  </div>
  {#if filter && showContributionFilter}
    <a class="filter" href={filterPathname} on:click={loadInternalLink}>{filter}</a>
  {/if}
</li>

<style lang="scss">
  @import "#general/scss/utils";
  a{
    color: inherit;
  }
  .operation{
    @include display-flex(row, center, flex-start);
    @include radius;
    background-color: white;
    margin: 0.2em 0;
    padding-inline-start: 0.5em;
    padding-inline-end: 0.5em;
    padding: 0.5em;
    color: $dark-grey;
    > div{
      display: inline-block;
    }
    .op{
      margin-inline-end: 1em;
      width: 3em;
    }
    .path{
      width: 10em;
      color: $grey;
      margin-inline-end: 1em;
    }
    .value{
      overflow: hidden;
      flex: 1;
    }
    .filter{
      @include tiny-button($light-blue);
      margin-inline-start: auto;
    }
  }
  .operation-add{
    .op{
      color: green;
    }
  }
  .operation-remove{
    .op{
      color: red;
    }
  }
  /* Small screens */
  @media screen and (width < $small-screen){
    .operation{
      flex-wrap: wrap;
    }
  }
</style>
