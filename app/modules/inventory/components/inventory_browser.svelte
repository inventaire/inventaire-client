<script>
  import { getSelectorsData } from '#inventory/components/lib/inventory_browser_helpers'
  import Spinner from '#components/spinner.svelte'
  import ItemsTable from '#inventory/components/items_table.svelte'
  import ItemsCascade from '#inventory/components/items_cascade.svelte'
  import PaginatedItems from '#inventory/components/paginated_items.svelte'
  import { onChange } from '#lib/svelte/svelte'
  import { getIntersectionWorkUris } from '#inventory/lib/browser/get_intersection_work_uris'
  import { clone, intersection, pick, uniq } from 'underscore'
  import InventoryBrowserControls from '#inventory/components/inventory_browser_controls.svelte'
  import { setContext } from 'svelte'
  import { getLocalStorageStore } from '#lib/components/stores/local_storage_stores'

  export let itemsDataPromise, isMainUser, ownerId, groupId, shelfId

  setContext('items-search-filters', { ownerId, groupId, shelfId })

  let itemsIds, textFilterItemsIds

  const inventoryDisplay = getLocalStorageStore('inventoryDisplay', 'cascade')

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

  let intersectionWorkUris
  function filterItems () {
    if (!(worksTree && facetsSelectedValues)) return
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
    if (textFilterItemsIds != null) {
      itemsIds = intersection(itemsIds, textFilterItemsIds)
    }
  }

  $: Component = $inventoryDisplay === 'cascade' ? ItemsCascade : ItemsTable
  $: onChange(facetsSelectedValues, textFilterItemsIds, filterItems)

  let items = [], pagination, componentProps = { isMainUser }

  async function setupPagination () {
    items = []
    componentProps.itemsIds = itemsIds
    const remainingItems = clone(itemsIds)
    pagination = {
      items,
      allowMore: true,
      hasMore: () => {
        return remainingItems.length > 0
      },
      fetchMore: async () => {
        const batch = remainingItems.splice(0, 20)
        if (batch.length > 0) {
          await app.request('items:getByIds', { ids: batch, items })
        }
        pagination.items = items
      },
    }
  }

  $: onChange(itemsIds, setupPagination)
</script>

<InventoryBrowserControls
  {waitForInventoryData}
  bind:facetsSelectors
  bind:facetsSelectedValues
  bind:textFilterItemsIds
  {intersectionWorkUris}
/>

{#await waitForInventoryData}
  <div class="spinner-wrap">
    <Spinner center={true} />
  </div>
{:then}
  <PaginatedItems
    {Component}
    {componentProps}
    {pagination}
    haveSeveralOwners={groupId != null}
  />
{/await}

<style lang="scss">
  @import "#general/scss/utils";
  .spinner-wrap{
    margin: 2em;
  }
</style>
