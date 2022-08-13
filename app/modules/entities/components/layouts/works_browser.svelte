<script>
  import SelectDropdown from '#components/select_dropdown.svelte'
  import WorkRow from '#entities/components/layouts/work_row.svelte'
  import Flash from '#lib/components/flash.svelte'
  import { i18n, I18n } from '#user/lib/i18n'
  import { entityProperties, getSelectedUris, getWorksFacets } from '#entities/components/lib/works_browser_helpers'
  import Spinner from '#components/spinner.svelte'
  import { onChange } from '#lib/svelte'

  export let works

  const displayOptions = [
    { value: 'grid', icon: 'th-large', text: I18n('grid') },
    { value: 'list', icon: 'align-justify', text: I18n('list') },
  ]

  let displayMode = 'grid'

  let flash, facets, facetsSelectedValues, facetsSelectors

  const waitForFacets = getWorksFacets(works)
    .then(res => ({ facets, facetsSelectedValues, facetsSelectors } = res))
    .catch(err => flash = err)

  let displayedWorks = works
  function filterWorks () {
    if (!facetsSelectedValues) return
    const selectedUris = getSelectedUris({ works, facets, facetsSelectedValues })
    displayedWorks = works.filter(work => selectedUris.has(work.uri))
  }

  $: onChange(facetsSelectedValues, filterWorks)
</script>

<Flash state={flash} />

<div class="works-browser">
  <div class="controls">
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

    <SelectDropdown bind:value={displayMode} options={displayOptions} buttonLabel={I18n('display_mode')}/>
  </div>

  <ul
    class:grid={displayMode === 'grid'}
    class:list={displayMode === 'list'}
    >
    {#each displayedWorks as work (work.uri)}
      <li>
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
