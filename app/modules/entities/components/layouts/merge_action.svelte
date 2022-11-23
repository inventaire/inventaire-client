<script>
  import Spinner from '#general/components/spinner.svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import mergeEntities from '#entities/views/editor/lib/merge_entities'
  import Flash from '#lib/components/flash.svelte'

  export let entity, parentEntity, isToMerge

  let waitForMerge, flash

  function merge () {
    if (!(entity && parentEntity)) return
    waitForMerge = mergeEntities(entity.uri, parentEntity.uri)
      .then(() => {
        flash = {
          type: 'success',
          message: I18n('merged')
        }
      })
      .catch(err => {
        flash = err
      })
  }
  $: { if (isToMerge) merge() }
</script>

{#await waitForMerge}
  <Spinner center={true} />
{/await}
{#if flash}
  <Flash bind:state={flash}/>
{:else}
  <button
    class="tiny-button"
    on:click|stopPropagation={merge}
  >
    {@html icon('compress')}
    {i18n('merge')}
  </button>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .tiny-button{
    padding: 0.5em;
  }
</style>
