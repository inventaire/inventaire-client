<script lang="ts">
  import { max } from 'underscore'
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import { propertiesType } from '#entities/components/lib/claims_helpers'
  import { propertiesPerType } from '#entities/lib/editor/properties_per_type'
  import { localizeDateString } from '#entities/lib/localize_date_string'
  import { I18n } from '#user/lib/i18n'
  import ClaimValue from './claim_value.svelte'

  export let prop
  export let values
  export let omitLabel = false
  export let entitiesByUris = {}
  export let entityType = null

  let propertyLabelI18nKey = prop
  if (entityType && propertiesPerType[entityType]?.[prop]) {
    propertyLabelI18nKey = propertiesPerType[entityType][prop].customLabel || prop
  }

  // Known case: values = [ '1954-07-29', '1954' ]
  // Assumptions: longest date is more precice and more accurate than shorter one

  const findLongestValue = values => max(values, v => v.length)

  let serializedValues = values
  if (propertiesType[prop] === 'timeClaim' && values) {
    const dateString = findLongestValue(values)
    serializedValues = [ localizeDateString(dateString) ]
  }
</script>
{#if serializedValues && isNonEmptyArray(serializedValues)}
  <div class="claim">
    {#if !omitLabel}
      <span class="property">
        {I18n(propertyLabelI18nKey)}:&nbsp;
      </span>
    {/if}
    <span class="values">
      {#each serializedValues as value, i}
        <ClaimValue
          {value}
          {prop}
          entity={entitiesByUris[value]}
        />{#if i !== serializedValues.length - 1},&nbsp;{/if}
      {/each}
    </span>
  </div>
{/if}
<style lang="scss">
  @import "#general/scss/utils";
  .property{
    color: $label-grey;
  }
  .claim{
    max-block-size: 5em;
    overflow-y: auto;
  }
</style>
