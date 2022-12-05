<script>
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import ClaimValue from './claim_value.svelte'
  import { i18n } from '#user/lib/i18n'

  export let prop,
    values,
    omitLabel = false,
    entitiesByUris
</script>
{#if values && isNonEmptyArray(values)}
  <div class="claim">
    {#if !omitLabel}
      <span class="property">
        {i18n(prop)}:&nbsp;
      </span>
    {/if}
    <span class="values">
      {#each values as value, i}
        <ClaimValue
          {value}
          {prop}
          entity={entitiesByUris[value]}
        />{#if i !== values.length - 1},{/if}
      {/each}
    </span>
  </div>
{/if}
<style lang="scss">
  @import "#general/scss/utils";
  .property{
    color: $grey;
  }
</style>
