<script lang="ts">
  import { flip } from 'svelte/animate'
  import Flash from '#app/lib/components/flash.svelte'
  import { screen } from '#app/lib/components/stores/screen'
  import { onScrollToBottom } from '#app/lib/screen'
  import { onChange } from '#app/lib/svelte/svelte'
  import { setIntersection } from '#app/lib/utils'
  import EntityListCompact from '#entities/components/layouts/entity_list_compact.svelte'
  import EntityListCompactTitleRow from '#entities/components/layouts/entity_list_compact_title_row.svelte'
  import EntityListRow from '#entities/components/layouts/entity_list_row.svelte'
  import MissingEntityButton from '#entities/components/layouts/missing_entity_button.svelte'
  import SectionLabel from '#entities/components/layouts/section_label.svelte'
  import SortEntitiesBy from '#entities/components/layouts/sort_entities_by.svelte'
  import WorkActions from '#entities/components/layouts/work_actions.svelte'
  import WorkGridCard from '#entities/components/layouts/work_grid_card.svelte'
  import { bySearchMatchScore, getSelectedUris } from '#entities/components/lib/works_browser_helpers'
  import { i18n } from '#user/lib/i18n'

  export let section, displayMode, facets, facetsSelectedValues, textFilterUris

  const { entities: works, searchable = true, sortingType, isCompactDisplay } = section
  const { label, context } = section

  let filteredWorks = works
  let paginatedWorks = []
  let flash
  if (context) {
    flash = {
      type: 'warning',
      message: context,
    }
  }

  function filterWorks () {
    if (!facetsSelectedValues) return
    if (textFilterUris && !searchable) {
      filteredWorks = []
      return
    }
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

  $: disabled = (textFilterUris && !searchable)
  $: onChange(facetsSelectedValues, textFilterUris, filterWorks)

  const worksPerRow = 8
  // Limit needs to be high enough to have enough elements in order to be scrollable
  // otherwise on:scroll wont be triggered
  const initialLimit = worksPerRow * 4
  let displayLimit = initialLimit

  let scrollableElement

  function resetWorks () {
    if (scrollableElement) scrollableElement.scroll({ top: 0, behavior: 'smooth' })
    displayLimit = initialLimit
    updatedPaginatedWorks()
  }

  function displayMore () {
    if (displayLimit < filteredWorks.length) {
      const incrementedDisplayLimit = displayLimit + (2 * worksPerRow)
      displayLimit = Math.min(incrementedDisplayLimit, filteredWorks.length)
    }
  }

  function updatedPaginatedWorks () {
    paginatedWorks = filteredWorks.slice(0, displayLimit)
  }

  $: onChange(displayLimit, updatedPaginatedWorks)
  $: anyWork = paginatedWorks.length > 0
  $: onChange(filteredWorks, resetWorks)
</script>

<div
  class="works-browser-section"
  class:section-without-work={!anyWork}
  class:disabled
  title={disabled ? i18n('Searching is not possible for this section yet') : ''}
>
  <div
    class="title-row"
    class:empty={!label}
  >
    {#if label}
      <SectionLabel
        {label}
        entitiesLength={works.length}
        filteredEntitiesLength={filteredWorks.length}
      />
    {/if}
    {#if paginatedWorks.length > 1}
      <SortEntitiesBy
        {sortingType}
        bind:entities={filteredWorks}
      />
    {/if}
  </div>
  <Flash bind:state={flash} />
  {#if anyWork}
    <ul
      class:grid={displayMode === 'grid'}
      class:list={displayMode === 'list'}
      on:scroll={onScrollToBottom(displayMore)}
      bind:this={scrollableElement}
    >
      {#if isCompactDisplay}
        <EntityListCompactTitleRow />
      {/if}
      {#each paginatedWorks as work (work.uri)}
        <li
          animate:flip={{ duration: 300 }}
          class:isCompactDisplay
        >
          {#if isCompactDisplay}
            <!-- known case: article -->
            <EntityListCompact
              entity={work}
              bind:relatedEntities={work.relatedEntities}
            />
          {:else if displayMode === 'grid'}
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
    </ul>
  {:else}
    <p class="no-work">{i18n('There is nothing here')}</p>
  {/if}
  <MissingEntityButton {section} />
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .works-browser-section{
    background-color: $off-white;
    padding: 0.5em;
    margin-block-end: 0.5em;
    @include display-flex(column);
    &.disabled{
      opacity: 0.5;
    }
  }
  .section-without-work{
    @include display-flex(row, center);
  }
  .title-row{
    @include display-flex(row, center, space-between, wrap);
    margin: 0.3em 0.5em;
  }
  ul{
    flex: 1;
    max-block-size: 42em;
    overflow-y: auto;
    &.list{
      align-self: stretch;
    }
    &.grid{
      @include display-flex(row, center, flex-start, wrap);
    }
    :global(.entity-wrapper){
      inline-size: 100%;
    }
  }
  li{
    @include display-flex(row, inherit, space-between);
  }
  .isCompactDisplay{
    inline-size: 100%;
  }
  .no-work{
    color: $grey;
    margin: auto;
  }
  /* Smaller screens */
  @media screen and (width < $smaller-screen){
    li{
      @include display-flex(column);
      :global(.actions-wrapper){
        margin-block: 1em 0;
      }
    }
  }
</style>
