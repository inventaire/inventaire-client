<script lang="ts">
  import { getContext } from 'svelte'
  import SelectDropdown from '#components/select_dropdown.svelte'
  import { entityProperties, getWorksFacets, getFacetsEntitiesBasicInfo } from '#entities/components/lib/works_browser_helpers'
  import { i18n } from '#user/lib/i18n'

  export let works, facets, facetsSelectors, facetsSelectedValues, flash

  const layoutContext = getContext('layout-context')
  const facetsObj = getWorksFacets({ works, context: layoutContext })

  const urisCount = facetsObj.valuesUris.length
  const loadingMessage = i18n('loading_facets_may_take_a_while', { smart_count: urisCount })

  ;({ facets, facetsSelectedValues } = facetsObj)
  const waitingForOptions = getFacetsEntitiesBasicInfo(facetsObj)
    .then(res => ({ facets, facetsSelectedValues, facetsSelectors } = res))
    .catch(err => flash = err)
</script>
{#each Object.keys(facets) as property}
  <SelectDropdown
    bind:value={facetsSelectedValues[property]}
    options={facetsSelectors?.[property].options}
    resetValue="all"
    {waitingForOptions}
    {loadingMessage}
    buttonLabel={i18n(property)}
    withImage={entityProperties.includes(property)}
  />
{/each}
<style lang="scss">
  @import "#general/scss/utils";
</style>
