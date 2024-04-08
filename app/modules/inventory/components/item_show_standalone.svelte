<script lang="ts">
  import app from '#app/app'
  import Modal from '#components/modal.svelte'
  import ItemShow from '#inventory/components/item_show.svelte'

  export let item, user, pathnameAfterClosingModal = null, autodestroyComponent = null

  function close () {
    if (pathnameAfterClosingModal) {
      app.navigate(pathnameAfterClosingModal, { preventScrollTop: true })
      autodestroyComponent()
    } else {
      app.execute('show:inventory:user', item.owner)
    }
  }
</script>

<Modal size="large" on:closeModal={close}>
  <ItemShow {item} {user} on:close={close} />
</Modal>
