<script>
  import SelectDropdown from '#components/select_dropdown.svelte'
  import WorkRow from '#entities/components/layouts/work_row.svelte'
  import Flash from '#lib/components/flash.svelte'
  import { I18n } from '#user/lib/i18n'
  import { bySearchMatchScore, getSelectedUris } from '#entities/components/lib/works_browser_helpers'
  import { onChange } from '#lib/svelte'
  import { flip } from 'svelte/animate'
  import WorksBrowserFacets from '#entities/components/layouts/works_browser_facets.svelte'
  import WorksBrowserTextFilter from '#entities/components/layouts/works_browser_text_filter.svelte'
  import { setIntersection } from '#lib/utils'

  export let works

  const displayOptions = [
    { value: 'grid', icon: 'th-large', text: I18n('grid') },
    { value: 'list', icon: 'align-justify', text: I18n('list') },
  ]

  let displayMode = 'grid'

  let flash, facets, facetsSelectedValues, facetsSelectors, textFilterUris

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

<Flash state={flash} />

<div class="works-browser">
  <div class="controls">
    <WorksBrowserFacets
      {works}
      bind:facets
      bind:facetsSelectors
      bind:facetsSelectedValues
      bind:flash
    />

    <WorksBrowserTextFilter bind:textFilterUris />

    <SelectDropdown bind:value={displayMode} options={displayOptions} buttonLabel={I18n('display_mode')}/>
  </div>

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
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .controls{
    background-color: $off-white;
    margin-bottom: 0.5em;
    @include radius;
    padding: 0.5em;
    @include display-flex(row, center, flex-start);
    :global(.select-dropdown){
      width: 10em;
      margin-right: 1em;
      &:last-child{
       margin-inline-start: auto;
      }
    }
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
