<script>
  import Spinner from '#general/components/spinner.svelte'
  import { i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import mergeEntities from '#entities/views/editor/lib/merge_entities'
  import Flash from '#lib/components/flash.svelte'
  import { createEventDispatcher } from 'svelte'
  import { isWikidataItemUri } from '#lib/boolean_tests'
  import Link from '#lib/components/link.svelte'
  import { getWikidataItemMergeUrl } from '#entities/lib/wikidata/init_entity'
  const dispatch = createEventDispatcher()

  export let fromEntityUri, targetEntityUri

  let waitForMerge, flash, merging = false

  const bothAreWikidataEntities = isWikidataItemUri(fromEntityUri) && isWikidataItemUri(targetEntityUri)

  export async function merge () {
    if (!(fromEntityUri && targetEntityUri)) return
    dispatch('isMerging')
    merging = true
    waitForMerge = mergeEntities(fromEntityUri, targetEntityUri)
      .then(() => dispatch('merged'))
      .catch(err => flash = err)
  }
</script>

{#if flash}
  <Flash bind:state={flash} />
{:else if bothAreWikidataEntities}
  <Link
    url={getWikidataItemMergeUrl(fromEntityUri, targetEntityUri)}
    text={i18n('Merge on Wikdiata')}
    icon="external-link"
    tinyButton={true}
  />
{:else}
  <button
    class="tiny-button merge"
    on:click|stopPropagation={merge}
    disabled={merging}
  >
    {#await waitForMerge}
      <Spinner center={true} light={true} />
    {:then}
      {@html icon('compress')}
    {/await}
    {i18n('merge')}
  </button>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .tiny-button{
    padding: 0.5em;
    @include display-flex(row, center, center);
  }
</style>
