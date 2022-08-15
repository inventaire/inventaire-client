<script>
  import WorkListRow from '#entities/components/layouts/work_list_row.svelte'
  import WorkGridCard from '#entities/components/layouts/work_grid_card.svelte'
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

<div class="works-browser-section">
  {#if label}
    <h3>{I18n(label)}</h3>
  {/if}

  <ul
    class:grid={displayMode === 'grid'}
    class:list={displayMode === 'list'}
    >
    {#each displayedWorks as work (work.uri)}
      <li animate:flip={{ duration: 300 }}>
        {#if displayMode === 'grid'}
          <WorkGridCard {work} />
        {:else}
          <WorkListRow {work} />
        {/if}
      </li>
    {/each}
  </ul>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .works-browser-section{
    background-color: $off-white;
    padding: 0.5em;
    margin-bottom: 0.5em;
  }
  h3{
    font-size: 1rem;
    margin: 0.5em 0.5em 0 0.5em;
  }
  ul{
    flex: 1;
    max-height: 42em;
    overflow-y: auto;
    &.list{
      margin: 0 auto;
    }
    &.grid{
      @include display-flex(row, center, flex-start, wrap);
    }
  }
</style>
