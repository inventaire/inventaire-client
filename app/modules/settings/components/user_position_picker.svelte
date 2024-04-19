<script lang="ts">
  import app from '#app/app'
  import Modal from '#components/modal.svelte'
  import PositionPicker from '#map/components/position_picker.svelte'
  import { user } from '#user/user_store'

  export let showPositionPicker

  async function savePosition (latLng) {
    return app.request('user:update', {
      attribute: 'position',
      value: latLng,
    })
  }
</script>

{#if showPositionPicker}
  <Modal size="large" on:closeModal={() => showPositionPicker = false}>
    <PositionPicker
      type="user"
      position={$user.position}
      {savePosition}
      on:positionPickerDone={() => showPositionPicker = false}
    />
  </Modal>
{/if}
