<script>
  import Spinner from '#general/components/spinner.svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import mergeEntities from '#entities/views/editor/lib/merge_entities'

  export let entity, parentEntity, childEvents, flash

  let isMerging

  function merge () {
    if (!(entity && parentEntity)) return
    if (isMerging) return
    isMerging = true
    mergeEntities(entity.uri, parentEntity.uri)
    .then(() => {
      flash = {
        type: 'success',
        message: I18n('merged')
      }
      parentEntity.merged = true
    })
    .catch(err => {
      flash = err
    })
    .finally(() => {
      isMerging = false
    })
  }
  childEvents = { merge }
</script>
<button
  class="tiny-button"
  on:click|stopPropagation={merge}
  >
  {#if isMerging}
    <Spinner/>
  {:else}
    {@html icon('compress')}
  {/if}
  {i18n('merge')}
</button>
<style lang="scss">
  @import '#general/scss/utils';
  .tiny-button{
    padding: 0.5em;
  }
</style>
