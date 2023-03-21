<script>
  import ShelvesSection from '#shelves/components/shelves_section.svelte'
  import ShelfBox from '#shelves/components/shelf_box.svelte'
  import InventoryBrowser from '#inventory/components/inventory_browser.svelte'
  import { getInventoryView } from '#inventory/components/lib/inventory_browser_helpers'
  import { getShelvesByOwner } from '#shelves/lib/shelves'
  import { onChange } from '#lib/svelte/svelte'

  export let user, selectedShelf, section = 'inventory', groupId = null, flash

  const { isMainUser } = user

  $: {
    if (!selectedShelf) {
      if (section === 'inventory') app.navigate(user.inventoryPathname)
      else if (section === 'listings') app.navigate(user.listingsPathname)
    }
  }

  function onSelectShelf (e) {
    selectedShelf = e.detail.shelf
  }
  function onCloseShelf (e) {
    selectedShelf = null
  }

  let shelves
  const waitForShelves = getShelvesByOwner(user._id)
    .then(res => {
      shelves = res
      if (selectedShelf) {
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
</script>

<ShelvesSection
  {waitForShelves}
  {user}
  {shelves}
  on:selectShelf={onSelectShelf}
/>

{#if selectedShelf === 'without-shelf'}
  <ShelfBox withoutShelf={true} on:closeShelf={onCloseShelf} />
  <InventoryBrowser
    itemsDataPromise={getInventoryView('without-shelf')}
    {isMainUser}
  />
{:else if selectedShelf}
  <ShelfBox bind:shelf={selectedShelf} on:closeShelf={onCloseShelf} />
  <!-- Recreate component when selectedShelf changes, see https://svelte.dev/docs#template-syntax-key -->
  {#key selectedShelf}
    <InventoryBrowser
      itemsDataPromise={getInventoryView('shelf', selectedShelf)}
      {isMainUser}
      shelfId={selectedShelf._id}
    />
  {/key}
{:else}
  <!-- TODO: recover display of InventoryWelcome for the main user -->
  <InventoryBrowser
    itemsDataPromise={getInventoryView('user', user)}
    ownerId={user._id}
    {groupId}
    {isMainUser}
  />
{/if}
