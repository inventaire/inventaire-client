<script>
  import Spinner from '#general/components/spinner.svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import mergeEntities from '#entities/views/editor/lib/merge_entities'

  export let entity, parentEntity, childEvents, flash

  let waitForMerge, merged

  function merge () {
    if (!(entity && parentEntity)) return
    waitForMerge = mergeEntities(entity.uri, parentEntity.uri)
      .then(() => {
        flash = {
          type: 'success',
          message: I18n('merged')
        }
        parentEntity.merged = merged = true
      })
      .catch(err => {
        flash = err
      })
  }
  childEvents = { merge }
</script>

{#await waitForMerge}
  <Spinner center={true}/>
{/await}

{#if !merged}
  <button
    class="tiny-button"
    on:click|stopPropagation={merge}
    >
    {@html icon('compress')}
    {i18n('merge')}
  </button>
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  .tiny-button{
    padding: 0.5em;
  }
</style>
