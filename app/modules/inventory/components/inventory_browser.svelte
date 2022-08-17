<script>
  import { I18n } from '#user/lib/i18n'
  import SelectDropdown from '#components/select_dropdown.svelte'
  import InventoryBrowserFacet from '#inventory/components/inventory_browser_facet.svelte'
  import { getSelectorsData } from '#inventory/components/lib/inventory_browser_helpers'
  import Spinner from '#components/spinner.svelte'
  import ItemsTable from '#inventory/components/items_table.svelte'
  import ItemsCascade from '#inventory/components/items_cascade.svelte'
  import PaginatedItems from '#inventory/components/paginated_items.svelte'
  import { onChange } from '#lib/svelte/svelte'
  import { getIntersectionWorkUris } from '#inventory/lib/browser/get_intersection_work_uris'
  import { clone, pick, uniq } from 'underscore'

  export let itemsDataPromise, isMainUser

  let itemsIds

  let worksTree, workUriItemsMap, itemsByDate
  const waitForInventoryData = itemsDataPromise
    .then(async res => {
      ;({ worksTree, workUriItemsMap, itemsByDate } = res)
      await showEntitySelectors()
    })

  let facetsSelectors, facetsSelectedValues
  async function showEntitySelectors () {
    ;({ facetsSelectors, facetsSelectedValues } = await getSelectorsData({ worksTree }))
  }

  const displayOptions = [
    { value: 'cascade', icon: 'th-large', text: I18n('cascade') },
    { value: 'list', icon: 'align-justify', text: I18n('list') },
  ]

  // TODO: persist display mode in localstorage
  let displayMode = 'cascade'

  let intersectionWorkUris
  function filterItems () {
    if (!worksTree) return
    intersectionWorkUris = getIntersectionWorkUris({ worksTree, facetsSelectedValues })
    if (intersectionWorkUris == null) {
      // Default to showing the latest items
      itemsIds = itemsByDate
    } else if (intersectionWorkUris.length === 0) {
      itemsIds = []
    } else {
      const worksItems = pick(workUriItemsMap, intersectionWorkUris)
      // Deduplicate as editions with several P629 values might have generated duplicates
      itemsIds = uniq(Object.values(worksItems).flat())
    }
  }

  $: Component = displayMode === 'cascade' ? ItemsCascade : ItemsTable
  $: onChange(facetsSelectedValues, filterItems)

  let items = [], pagination, componentProps = { isMainUser }

  async function setupPagination () {
    items = []
    componentProps.itemsIds = itemsIds
    const remainingItems = clone(itemsIds)
    pagination = {
      allowMore: true,
      hasMore: () => remainingItems.length > 0,
      fetchMore: async () => {
        const batch = remainingItems.splice(0, 20)
        if (batch.length === 0) return
        await app.request('items:getByIds', { ids: batch, items })
        pagination.items = items
      },
    }
  }

  $: onChange(itemsIds, setupPagination)
</script>

<div class="controls" class:ready={facetsSelectors != null}>
  <div class="filters">
    <span class="control-label">{I18n('filters')}</span>
    {#await waitForInventoryData}
      <Spinner center={true} />
    {:then}
      <div class="selectors">
        {#each Object.keys(facetsSelectors) as sectionName}
          <InventoryBrowserFacet
            bind:facetsSelectors
            bind:facetsSelectedValues
            {sectionName}
            {intersectionWorkUris}
          />
        {/each}
      </div>
    {/await}
  </div>
  <div class="display-controls">
    <SelectDropdown bind:value={displayMode} options={displayOptions} buttonLabel={I18n('display_mode')}/>
  </div>
</div>

{#await waitForInventoryData}
  <Spinner center={true} />
{:then}
  <PaginatedItems {Component} {componentProps} {pagination} />
{/await}

<style lang="scss">
  @import '#general/scss/utils';
  .controls, .filters{
    @include display-flex(row, center, center, wrap);
    @include radius;
    /*Small screens*/
    @media screen and (max-width: $smaller-screen) {
      padding: 0.3em 0 0.2em 0;
    }
    /*Large screens*/
    @media screen and (min-width: $smaller-screen) {
      padding: 0.2em 0.5em;
    }
  }
  .controls{
    background-color: $inventory-nav-grey;
    @include transition(opacity);
    opacity: 1;
    margin: 0.5em 0 0.5em 0;
    &:not(.ready){
      .filters{
        flex: 1 0 0;
      }
    }
  }
  .display-controls{
    /*Large screens*/
    @media screen and (min-width: $smaller-screen) {
      margin-left: auto;
    }
  }
  .control-label{
    color: $grey;
    /*Large screens*/
    @media screen and (min-width: $smaller-screen) {
      margin: 1em 0.5em;
    }
  }
  .selectors{
    @include display-flex(row, center, center, wrap);
  }

  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .controls{
      flex-direction: column;
    }
    .filters{
      flex-direction: column;
    }
    .selectors{
      flex-direction: column;
    }
    .display-controls{
      margin: 1em;
    }
  }
</style>
