<script>
  import WorkRow from '#entities/components/layouts/work_row.svelte'
  import { I18n } from '#user/lib/i18n'
  import { bySearchMatchScore, getSelectedUris } from '#entities/components/lib/works_browser_helpers'
  import { onChange } from '#lib/svelte'
  import { flip } from 'svelte/animate'
  import { setIntersection } from '#lib/utils'

  export let section, displayMode, facets, facetsSelectedValues, textFilterUris

  const { label, entities: works } = section

  // TODO: display only the first n items, and add more on scroll
  let displayedWorks = works
  function filterWorks () {
    if (!facetsSelectedValues) return
    let selectedUris = getSelectedUris({ works, facets, facetsSelectedValues })
    if (textFilterUris) selectedUris = setIntersection(selectedUris, textFilterUris)
    displayedWorks = works.filter(work => selectedUris.has(work.uri))
    if (textFilterUris) {
      displayedWorks = displayedWorks.sort(bySearchMatchScore(textFilterUris))
    }
  }

  $: onChange(facetsSelectedValues, textFilterUris, filterWorks)
</script>

{#if label}
  <h3>{I18n(label)}</h3>
{/if}

<ul
  class:grid={displayMode === 'grid'}
  class:list={displayMode === 'list'}
  >
  {#each displayedWorks as work (work.uri)}
    <li animate:flip={{ duration: 300 }}>
      <WorkRow {work} {displayMode} />
    </li>
  {/each}
</ul>

<style lang="scss">
  @import '#general/scss/utils';
  h3{
    font-size: 1rem;
    margin: 0.5em 0.5em 0 0.5em;
  }
  ul{
    flex: 1;
    &.list{
      max-width: 40em;
      margin: 0 auto;
    }
    &.grid{
      @include display-flex(row, center, flex-start, wrap);
    }
  }
</style>
