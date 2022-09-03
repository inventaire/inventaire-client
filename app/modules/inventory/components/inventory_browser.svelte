<script>
  import { getSelectorsData } from '#inventory/components/lib/inventory_browser_helpers'
  import Spinner from '#components/spinner.svelte'
  import ItemsTable from '#inventory/components/items_table.svelte'
  import ItemsCascade from '#inventory/components/items_cascade.svelte'
  import PaginatedItems from '#inventory/components/paginated_items.svelte'
  import { onChange } from '#lib/svelte/svelte'
  import { getIntersectionWorkUris } from '#inventory/lib/browser/get_intersection_work_uris'
  import { clone, pick, uniq } from 'underscore'
  import InventoryBrowserControls from '#inventory/components/inventory_browser_controls.svelte'

  export let itemsDataPromise, isMainUser

  let itemsIds

  // TODO: persist display mode in localstorage
  let displayMode = 'cascade'

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

<InventoryBrowserControls
  {waitForInventoryData}
  bind:displayMode
  bind:facetsSelectors
  bind:facetsSelectedValues
  {intersectionWorkUris}
/>

{#await waitForInventoryData}
  <Spinner center={true} />
{:then}
  <PaginatedItems {Component} {componentProps} {pagination} />
{/await}