<script>
  import { getFilteredItemsIds, getSelectorsData, resetPagination } from '#inventory/components/lib/inventory_browser_helpers'
  import Spinner from '#components/spinner.svelte'
  import PaginatedItems from '#inventory/components/paginated_items.svelte'
  import { onChange } from '#lib/svelte/svelte'
  import { getIntersectionWorkUris } from '#inventory/lib/browser/get_intersection_work_uris'
  import { debounce } from 'underscore'
  import InventoryBrowserControls from '#inventory/components/inventory_browser_controls.svelte'
  import { setContext } from 'svelte'
  import { getLocalStorageStore } from '#lib/components/stores/local_storage_stores'
  import InventoryWelcome from '#inventory/components/inventory_welcome.svelte'

  export let itemsDataPromise
  export let isMainUser = false
  export let ownerId = null
  export let groupId = null
  export let shelfId = null
  export let itemsShelvesByIds = null

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

  let intersectionWorkUris, pagination

  function updateDisplayedItems () {
    if (!(worksTree && facetsSelectedValues)) return
    intersectionWorkUris = getIntersectionWorkUris({ worksTree, facetsSelectedValues })
    itemsIds = getFilteredItemsIds({ intersectionWorkUris, itemsByDate, workUriItemsMap, textFilterItemsIds })
    pagination = resetPagination({ itemsIds, isMainUser, display: $inventoryDisplay })
  }

  const lazyUpdateDisplayedItems = debounce(updateDisplayedItems, 100)

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
        display={$inventoryDisplay}
        {itemsIds}
        {itemsShelvesByIds}
        {isMainUser}
        {pagination}
        haveSeveralOwners={ownerId == null}
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
