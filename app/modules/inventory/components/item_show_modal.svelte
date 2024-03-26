<script>
  import app from '#app/app'
  import Modal from '#components/modal.svelte'
  import ItemShow from '#inventory/components/item_show.svelte'
  import { currentRoute } from '#lib/location'

  export let item, showItemModal

  let pathnameBeforeModal

  function closeItemModalAndFallback () {
    app.navigate(pathnameBeforeModal, { preventScrollTop: true })
    closeItemModal()
  }

  function closeItemModal () {
    showItemModal = false
  }

  // This works because the reactive block runs before
  // ItemShow calls app.navigate on initialization
  $: if (showItemModal) pathnameBeforeModal = currentRoute()
</script>

{#if showItemModal}
  <Modal size="large" on:closeModal={closeItemModalAndFallback}>
    <ItemShow
      bind:item
      user={item.user}
      on:close={closeItemModalAndFallback}
      on:navigate={closeItemModal}
    />
  </Modal>
{/if}
