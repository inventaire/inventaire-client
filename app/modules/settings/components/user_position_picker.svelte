<script lang="ts">
  import Modal from '#components/modal.svelte'
  import PositionPicker from '#map/components/position_picker.svelte'
  import { mainUser, updateUser } from '#user/lib/main_user'

  export let showPositionPicker

  async function savePosition (latLng) {
    return updateUser('position', latLng)
  }
</script>

{#if showPositionPicker}
  <Modal size="large" on:closeModal={() => showPositionPicker = false}>
    <PositionPicker
      type="user"
      position={$mainUser.position}
      {savePosition}
      on:positionPickerDone={() => showPositionPicker = false}
    />
  </Modal>
{/if}
