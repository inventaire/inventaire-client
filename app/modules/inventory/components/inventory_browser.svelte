<script>
  import { getFilteredItemsIds, getSelectorsData, setupPagination } from '#inventory/components/lib/inventory_browser_helpers'
  import Spinner from '#components/spinner.svelte'
  import ItemsTable from '#inventory/components/items_table.svelte'
  import ItemsCascade from '#inventory/components/items_cascade.svelte'
  import PaginatedItems from '#inventory/components/paginated_items.svelte'
  import { onChange } from '#lib/svelte/svelte'
  import { getIntersectionWorkUris } from '#inventory/lib/browser/get_intersection_work_uris'
  import { debounce } from 'underscore'
  import InventoryBrowserControls from '#inventory/components/inventory_browser_controls.svelte'
  import { setContext } from 'svelte'
  import { getLocalStorageStore } from '#lib/components/stores/local_storage_stores'
  import InventoryWelcome from '#inventory/components/inventory_welcome.svelte'

  export let itemsDataPromise, isMainUser, ownerId, groupId, shelfId

  setContext('items-search-filters', { ownerId, groupId, shelfId })

  let itemsIds, textFilterItemsIds

  const inventoryDisplay = getLocalStorageStore('inventoryDisplay', 'cascade')

  let showInventoryWelcome = false

  let worksTree, workUriItemsMap, itemsByDate
  const waitForInventoryData = itemsDataPromise
    .then(async res => {
      ;({ worksTree, workUriItemsMap, itemsByDate } = res)
      if (itemsByDate.length === 0 && ownerId === app.user.id) {
        showInventoryWelcome = true
      } else {
        await showEntitySelectors()
      }
    })

  let facetsSelectors, facetsSelectedValues
  async function showEntitySelectors () {
    ;({ facetsSelectors, facetsSelectedValues } = await getSelectorsData({ worksTree }))
  }

  let intersectionWorkUris, pagination, componentProps = { isMainUser }

  function updateDisplayedItems () {
    if (!(worksTree && facetsSelectedValues)) return
    intersectionWorkUris = getIntersectionWorkUris({ worksTree, facetsSelectedValues })
    itemsIds = getFilteredItemsIds({ intersectionWorkUris, itemsByDate, workUriItemsMap, textFilterItemsIds })
    componentProps.itemsIds = itemsIds
    pagination = setupPagination({ itemsIds, isMainUser, display: $inventoryDisplay })
  }

  const lazyUpdateDisplayedItems = debounce(updateDisplayedItems, 100)

  $: Component = $inventoryDisplay === 'cascade' ? ItemsCascade : ItemsTable
  $: onChange(facetsSelectedValues, textFilterItemsIds, lazyUpdateDisplayedItems)
</script>

{#if showInventoryWelcome}
  <InventoryWelcome />
{:else}
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
    {#if pagination}
      <PaginatedItems
        {Component}
        {componentProps}
        {pagination}
        haveSeveralOwners={groupId != null}
      />
    {/if}
  {/await}
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .spinner-wrap{
    margin: 2em;
  }
</style>
