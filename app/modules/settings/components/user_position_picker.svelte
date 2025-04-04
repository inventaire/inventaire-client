<script lang="ts">
  import Modal from '#components/modal.svelte'
  import PositionPicker from '#map/components/position_picker.svelte'
  import { mainUserStore, updateUser } from '#user/lib/main_user'

  export let showPositionPicker

  async function savePosition (latLng) {
    return updateUser('position', latLng)
  }
</script>

{#if showPositionPicker}
  <Modal size="large" on:closeModal={() => showPositionPicker = false}>
    <PositionPicker
      type="user"
      position={$mainUserStore.position}
      {savePosition}
      on:positionPickerDone={() => showPositionPicker = false}
    />
  </Modal>
{/if}
