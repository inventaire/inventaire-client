<script>
  import SelectDropdown from '#components/select_dropdown.svelte'
  import { i18n } from '#user/lib/i18n'
  import { entityProperties, getWorksFacets } from '#entities/components/lib/works_browser_helpers'
  import Spinner from '#components/spinner.svelte'
  import { getContext } from 'svelte'

  export let works, facets, facetsSelectors, facetsSelectedValues, flash

  const layoutContext = getContext('layout-context')

  const waitForFacets = getWorksFacets({ works, context: layoutContext })
    .then(res => ({ facets, facetsSelectedValues, facetsSelectors } = res))
    .catch(err => flash = err)
</script>

{#await waitForFacets}
  <Spinner />
{:then}
  {#each Object.keys(facets) as property}
    {#if !facetsSelectors[property].disabled}
      <SelectDropdown
        bind:value={facetsSelectedValues[property]}
        options={facetsSelectors[property].options}
        resetValue='all'
        buttonLabel={i18n(property)}
        withImage={entityProperties.includes(property)}
      />
    {/if}
  {/each}
{/await}
