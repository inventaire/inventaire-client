<script>
  import { propertiesType } from '#entities/components/lib/claims_helpers'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import ClaimValue from './claim_value.svelte'
  import { i18n } from '#user/lib/i18n'

  export let prop,
    values,
    omitLabel = false,
    entitiesByUris

  // Known case: values = [ '1954-07-29', '1954' ]
  // Assumptions: longest date is more precice and more accurate than shorter one
  const findLongestDate = values => [ _.max(values, v => v.length) ]

  if (propertiesType[prop] === 'timeClaim' && values && values.length > 1) {
    values = findLongestDate(values)
  }
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
    color: $label-grey;
  }
</style>
