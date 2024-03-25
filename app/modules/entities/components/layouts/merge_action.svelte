<script>
  import { createEventDispatcher } from 'svelte'
  import { getWikidataItemMergeUrl } from '#entities/lib/wikidata/init_entity'
  import mergeEntities from '#entities/views/editor/lib/merge_entities'
  import Spinner from '#general/components/spinner.svelte'
  import { isWikidataItemUri } from '#lib/boolean_tests'
  import Flash from '#lib/components/flash.svelte'
  import Link from '#lib/components/link.svelte'
  import { icon } from '#lib/icons'
  import { i18n } from '#user/lib/i18n'

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

<div class="merge-action">
  {#if flash}
    <Flash bind:state={flash} />
  {:else if bothAreWikidataEntities}
    <Link
      url={getWikidataItemMergeUrl(fromEntityUri, targetEntityUri)}
      text={i18n('Merge on Wikdiata')}
      icon="external-link"
      tinyButton={true}
      classNames="wikidata"
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
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .merge-action{
    :global(.wikidata){
      background-color: $wikidata-green;
      padding: 0.4em 0.5em;
    }
  }
  .merge{
    padding: 0.4em 0.5em;
    @include display-flex(row, center, center);
  }
</style>
