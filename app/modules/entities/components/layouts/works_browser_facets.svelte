<script>
  import SelectDropdown from '#components/select_dropdown.svelte'
  import { i18n } from '#user/lib/i18n'
  import { entityProperties, getWorksFacets } from '#entities/components/lib/works_browser_helpers'
  import Spinner from '#components/spinner.svelte'

  export let works, facets, facetsSelectors, facetsSelectedValues, flash

  const waitForFacets = getWorksFacets(works)
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
