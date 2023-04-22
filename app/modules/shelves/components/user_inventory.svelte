<script>
  import ShelvesSection from '#shelves/components/shelves_section.svelte'
  import ShelfBox from '#shelves/components/shelf_box.svelte'
  import InventoryBrowser from '#inventory/components/inventory_browser.svelte'
  import { getInventoryView } from '#inventory/components/lib/inventory_browser_helpers'
  import { getShelvesByOwner } from '#shelves/lib/shelves'
  import { onChange } from '#lib/svelte/svelte'
  import { indexBy } from 'underscore'

  export let user
  export let selectedShelf = null
  export let groupId = null
  export let flash
  export let focusStore

  const { isMainUser } = user

  function onSelectShelf (e) {
    selectedShelf = e.detail.shelf
    $focusStore = { type: 'shelf' }
  }
  function onCloseShelf (e) {
    selectedShelf = null
    $focusStore = { type: 'user' }
  }

  let shelves, userShelvesById
  const waitForShelves = getShelvesByOwner(user._id)
    .then(res => {
      shelves = res
      if (selectedShelf && selectedShelf !== 'without-shelf') {
        // Replace the shelf object passed by the parent component by the one in the shelves array
        // so that changes made in the ShelfBox propagate to the ShelvesSection
        selectedShelf = shelves.find(({ _id }) => _id === selectedShelf._id)
      }
    })
    .catch(err => flash = err)

  // Required to propagate changes done on the selected shelf
  function refreshShelves () {
    shelves = shelves
  }
  $: onChange(selectedShelf, refreshShelves)
  $: if (shelves) userShelvesById = indexBy(shelves, '_id')
</script>

<ShelvesSection
  {waitForShelves}
  {user}
  {shelves}
  on:selectShelf={onSelectShelf}
/>

{#if selectedShelf === 'without-shelf'}
  <ShelfBox
    withoutShelf={true}
    on:closeShelf={onCloseShelf}
    {isMainUser}
    itemsShelvesByIds={userShelvesById}
    {focusStore}
  />
{:else if selectedShelf}
  <ShelfBox
    bind:shelf={selectedShelf}
    on:closeShelf={onCloseShelf}
    {isMainUser}
    itemsShelvesByIds={userShelvesById}
    {focusStore}
  />
{:else}
  <InventoryBrowser
    itemsDataPromise={getInventoryView('user', user)}
    ownerId={user._id}
    {groupId}
    {isMainUser}
    itemsShelvesByIds={userShelvesById}
  />
{/if}
