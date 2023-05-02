<script>
  import { getFilteredItemsIds, getInventoryDisplayStore, getSelectorsData, resetPagination } from '#inventory/components/lib/inventory_browser_helpers'
  import Spinner from '#components/spinner.svelte'
  import PaginatedItems from '#inventory/components/paginated_items.svelte'
  import { BubbleUpComponentEvent, onChange } from '#lib/svelte/svelte'
  import { getIntersectionWorkUris } from '#inventory/lib/browser/get_intersection_work_uris'
  import { debounce } from 'underscore'
  import InventoryBrowserControls from '#inventory/components/inventory_browser_controls.svelte'
  import { createEventDispatcher, setContext } from 'svelte'
  import InventoryWelcome from '#inventory/components/inventory_welcome.svelte'
  import Flash from '#lib/components/flash.svelte'

  export let itemsDataPromise
  export let isMainUser = false
  export let ownerId = null
  export let groupId = null
  export let shelfId = null
  export let itemsShelvesByIds = null

  setContext('items-search-filters', { ownerId, groupId, shelfId })

  let itemsIds, textFilterItemsIds, flash

  const inventoryDisplay = getInventoryDisplayStore(isMainUser)

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
    .catch(err => flash = err)

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

  const dispatch = createEventDispatcher()
  const bubbleUpComponentEvent = BubbleUpComponentEvent(dispatch)
</script>

<Flash state={flash} />
{#if showInventoryWelcome}
  <InventoryWelcome />
{:else}
  <InventoryBrowserControls
    {waitForInventoryData}
    bind:facetsSelectors
    bind:facetsSelectedValues
    bind:textFilterItemsIds
    {intersectionWorkUris}
    {inventoryDisplay}
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
        {shelfId}
        {isMainUser}
        {pagination}
        haveSeveralOwners={ownerId == null}
        on:selectShelf={bubbleUpComponentEvent}
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
