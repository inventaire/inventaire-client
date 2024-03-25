<script>
  import { intersection, pluck, without } from 'underscore'
  import FacetSelector from '#general/components/facet_selector.svelte'
  import { onChange } from '#lib/svelte/svelte'
  import { I18n } from '#user/lib/i18n'

  export let sectionName, facetsSelectors, facetsSelectedValues, intersectionWorkUris

  const { options } = facetsSelectors[sectionName]

  let displayedOptions, optionsCount
  function filterOptions () {
    options.forEach(refreshIntersection)
    if (intersectionWorkUris) {
      displayedOptions = options.filter(option => option.intersection.length > 0)
    } else {
      displayedOptions = options
    }
    optionsCount = without(pluck(displayedOptions, 'value'), 'unknown').length
  }

  function refreshIntersection (option) {
    if (intersectionWorkUris) {
      option.intersection = intersection(option.worksUris, intersectionWorkUris)
    } else {
      option.intersection = option.worksUris
    }
    option.count = option.intersection.length
  }

  $: onChange(intersectionWorkUris, filterOptions)
</script>

<FacetSelector
  bind:value={facetsSelectedValues[sectionName]}
  {displayedOptions}
  {optionsCount}
  buttonLabel={I18n(sectionName)}
/>
