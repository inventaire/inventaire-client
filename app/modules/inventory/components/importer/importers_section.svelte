<script lang="ts">
  import { compact, clone } from 'underscore'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import log_ from '#app/lib/loggers'
  import { scrollToElement } from '#app/lib/screen'
  import Counter from '#components/counter.svelte'
  import Spinner from '#components/spinner.svelte'
  import { addExistingItemsCounts, createExternalEntry, getExternalEntriesEntities } from '#inventory/components/importer/lib/importers_section_helpers'
  import { createCandidate, byIndex } from '#inventory/lib/importer/import_helpers'
  import importers from '#inventory/lib/importer/importers'
  import { I18n } from '#user/lib/i18n'
  import FileImporter from './file_importer.svelte'
  import IsbnImporter from './isbn_importer.svelte'

  export let candidates
  export let isbns: string[] = null
  export let processing = false
  export let isbnImporterEl = null
  export let processedExternalEntriesCount = 0
  export let totalExternalEntries = 0

  let cancelled
  let externalEntries = []
  let flashBlockingProcess
  let bottomSectionElement = {}

  const startedWithIsbns = isbns != null

  const createExternalEntries = candidatesData => {
    flashBlockingProcess = null
    externalEntries = compact(candidatesData.map(createExternalEntry))
  }

  const createCandidatesQueue = async () => {
    cancelled = false
    processedExternalEntriesCount = 0
    totalExternalEntries = externalEntries.length
    const remainingExternalEntries = clone(externalEntries)
    if (startedWithIsbns) scrollToElement(isbnImporterEl)
    else scrollToElement(bottomSectionElement)

    const createCandidateOneByOne = async () => {
      if (cancelled) return processedExternalEntriesCount = 0
      if (remainingExternalEntries.length === 0) return
      const externalEntry = remainingExternalEntries.pop()
      try {
        // Wont prevent duplicated candidates when 2 identical isbns are processed
        // at the same time in separate threads (see below createCandidatesQueue)
        // this is acceptable, as long as it prevents duplicates from one import to another
        const entitiesRes = await getExternalEntriesEntities(externalEntry)
        createAndAssignCandidate(externalEntry, entitiesRes)
        await createCandidateOneByOne()
      } catch (err) {
        // Log errors without throwing to prevent crashing the whole chain
        log_.error(err, 'createCandidateOneByOne err')
      }
    }

    return Promise.all([
      // Using 5 separate channels, fetching entities one by one, instead of
      // by batch, to avoid having one entity blocking a batch progression:
      createCandidateOneByOne(),
      createCandidateOneByOne(),
      createCandidateOneByOne(),
      createCandidateOneByOne(),
      createCandidateOneByOne(),
    ])
      .then(async () => {
        // Display candidates in the order of the input
      // to help the user fill the missing information
        candidates = candidates.sort(byIndex)
        // Add counts only now in order to handle entities redirects
        await addExistingItemsCounts({ candidates, externalEntries })
      })
  }

  const createAndAssignCandidate = (externalEntry, entities) => {
    processedExternalEntriesCount += 1
    const newCandidate = createCandidate(externalEntry, entities)
    candidates = [ ...candidates, newCandidate ]
  }

  $: processing = (processedExternalEntriesCount !== totalExternalEntries) && totalExternalEntries > 0
</script>
<h3>1/ {I18n('upload your books from another website')}</h3>
<ul class="importers">
  {#each importers as importer (importer.name)}
    <li>
      <FileImporter
        {importer}
        on:createExternalEntries={e => createExternalEntries(e.detail)}
        on:createCandidatesQueue={createCandidatesQueue}
      />
    </li>
  {/each}
  <li bind:this={isbnImporterEl}>
    <IsbnImporter
      on:createExternalEntries={e => createExternalEntries(e.detail)}
      on:createCandidatesQueue={createCandidatesQueue}
      {isbns}
    />
  </li>
</ul>
<Flash bind:state={flashBlockingProcess} />
<div bind:this={bottomSectionElement} />
{#if processing && !cancelled}
  <div class="processing-menu">
    <Counter count={processedExternalEntriesCount} total={totalExternalEntries} />
    <button
      class="grey-button dangerous"
      disabled={cancelled}
      on:click={() => {
        processing = false
        cancelled = true
      }}
    >
      {#if cancelled}
        <Spinner />
      {:else}
        {@html icon('ban')}
      {/if}
      {I18n('cancel')}
    </button>
  </div>
{/if}
<style lang="scss">
  @import "#modules/general/scss/utils";
  h3{
    padding-inline-start: 0.2em;
    font-weight: bold;
    margin-block-start: 1em;
    text-align: center;
  }
  li{
    margin: 0.5em 0;
    padding: 0.5em;
    background-color: #fefefe;
  }
  .processing-menu{
    @include display-flex(column, center, center);
    .grey-button{
      :global(.fa){
        color: white;
      }
    }
  }
</style>
