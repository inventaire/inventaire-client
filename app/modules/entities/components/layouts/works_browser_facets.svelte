<script>
  import SelectDropdown from '#components/select_dropdown.svelte'
  import { entityProperties, getWorksFacets, getFacetsSelectors } from '#entities/components/lib/works_browser_helpers'
  import { getContext } from 'svelte'
  import { i18n, I18n } from '#user/lib/i18n'

  export let works, facets, facetsSelectors, facetsSelectedValues, flash

  const layoutContext = getContext('layout-context')
  const facetsObj = getWorksFacets({ works, context: layoutContext })

  let loadingMessage
  const displayLoadingInfoMessage = async facetsObj => {
    const urisSize = facetsObj.valuesUris.length
    loadingMessage = I18n('loading_may_take_a_while', { smart_count: urisSize })
  }

  ({ facets, facetsSelectedValues } = facetsObj)
  Promise.all([
    getFacetsSelectors(facetsObj),
    displayLoadingInfoMessage(facetsObj)
  ])
  .then(res => ({ facets, facetsSelectedValues, facetsSelectors } = res[0]))
  .catch(err => flash = err)
  .finally(() => loadingMessage = false)
</script>
{#each Object.keys(facets) as property}
  <SelectDropdown
    bind:value={facetsSelectedValues[property]}
    options={facetsSelectors?.[property].options}
    resetValue='all'
    {loadingMessage}
    buttonLabel={i18n(property)}
    withImage={entityProperties.includes(property)}
  />
{/each}
<style lang="scss">
  @import '#general/scss/utils';
</style>
