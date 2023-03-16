<script>
  import Spinner from '#general/components/spinner.svelte'
  import EntityListRow from '#entities/components/layouts/entity_list_row.svelte'
  import SectionLabel from '#entities/components/layouts/section_label.svelte'
  import WorkGridCard from '#entities/components/layouts/work_grid_card.svelte'
  import WorkActions from '#entities/components/layouts/work_actions.svelte'
  import { addWorksImages } from '#entities/lib/types/work_alt'
  import { bySearchMatchScore, getSelectedUris } from '#entities/components/lib/works_browser_helpers'
  import { flip } from 'svelte/animate'
  import { i18n } from '#user/lib/i18n'
  import { onChange } from '#lib/svelte/svelte'
  import { setIntersection } from '#lib/utils'
  import { screen } from '#lib/components/stores/screen'

  export let section, displayMode, facets, facetsSelectedValues, textFilterUris

  const { entities: works } = section
  let { label } = section

  let filteredWorks = works
  let paginatedWorks = []

  function filterWorks () {
    if (!facetsSelectedValues) return
    let selectedUris = getSelectedUris({ works, facets, facetsSelectedValues })
    if (textFilterUris) selectedUris = setIntersection(selectedUris, textFilterUris)
    filteredWorks = works.filter(filterSelectedWorks(selectedUris, facetsSelectedValues))
    if (textFilterUris) {
      filteredWorks = filteredWorks.sort(bySearchMatchScore(textFilterUris))
    }
  }

  const filterSelectedWorks = (selectedUris, facetsSelectedValues) => work => {
    const { uri } = work
    return selectedUris.has(uri) || isSelectedEntityAParent(uri, facetsSelectedValues)
  }

  const isSelectedEntityAParent = (uri, facetsSelectedValues) => {
    // ie. if a collection is selected, display the collection in question.
    // TODO: generalize pattern to series
    return facetsSelectedValues['wdt:P195'] === uri
  }

  $: onChange(facetsSelectedValues, textFilterUris, filterWorks)

  function onWorksScroll (e) {
    const { scrollTop, scrollTopMax } = e.currentTarget
    if (scrollTopMax < 100) return
    if (scrollTop + 100 > scrollTopMax) displayLimit += 10
  }

  // Limit needs to be high enough to have enough elements in order to be scrollable
  // otherwise on:scroll wont be triggered
  let initialLimit = 25
  let displayLimit = initialLimit

  let scrollableElement

  async function addMoreWorks () {
    paginatedWorks = filteredWorks.slice(0, displayLimit)
    await addImagesToPaginatedWorks()
  }

  async function addImagesToPaginatedWorks () {
    paginatedWorks = await addWorksImages(paginatedWorks)
  }

  function resetView () {
    if (scrollableElement) scrollableElement.scroll({ top: 0, behavior: 'smooth' })
    displayLimit = initialLimit
  }

  $: onChange(displayLimit, addMoreWorks)
  $: onChange(displayMode, resetView)
  $: onChange(filteredWorks, resetView, addMoreWorks)
  $: anyWork = paginatedWorks.length > 0
</script>

<div
  class="works-browser-section"
  class:section-without-work={!anyWork}
>
  {#if label}
    <SectionLabel
      {label}
      entitiesLength={works.length}
      filteredEntitiesLength={filteredWorks.length}
    />
  {/if}
  {#if anyWork}
    <ul
      class:grid={displayMode === 'grid'}
      class:list={displayMode === 'list'}
      on:scroll={onWorksScroll}
      bind:this={scrollableElement}
    >
      {#await addImagesToPaginatedWorks()}
        <p class="loading"><Spinner /></p>
      {:then}
        {#each paginatedWorks as work (work.uri)}
          <li animate:flip={{ duration: 300 }}>
            {#if displayMode === 'grid'}
              <WorkGridCard {work} />
            {:else}
              <EntityListRow
                entity={work}
                bind:relatedEntities={work.relatedEntities}
                listDisplay={true}
              >
                <WorkActions
                  slot="actions"
                  entity={work}
                  align={$screen.isSmallerThan('$smaller-screen') ? 'center' : 'right'}
                />
              </EntityListRow>
            {/if}
          </li>
        {/each}
      {/await}
    </ul>
  {:else}
    <p class="no-work">{i18n('There is nothing here')}</p>
  {/if}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .works-browser-section{
    background-color: $off-white;
    padding: 0.5em;
    margin-bottom: 0.5em;
  }
  .section-without-work{
    @include display-flex(row, center);
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
    :global(.entity-wrapper){
      margin: 0.5em 0;
      padding: 0.5em;
      background-color: white;
    }
  }
  .loading{
    margin: 0 auto;
  }
  li{
    @include display-flex(row, inherit, space-between);
    background-color: white;
  }
  .no-work{
    color: $grey;
    margin: auto;
  }
  /* Small screens */
  @media screen and (max-width: $smaller-screen){
    li{
      @include display-flex(column);
      margin-bottom: 0.5em;
      padding: 0;
    }
  }
</style>
