<script>
  import { I18n } from '#user/lib/i18n'
  import Flash from '#lib/components/flash.svelte'
  import importers from '#inventory/lib/importer/importers'
  import {
    guessUriFromIsbn,
    createCandidate,
    noNewCandidates,
    byIndex,
    addExistingItemsCountToCandidate,
    resolveCandidate,
    getEditionEntitiesByUri,
    getRelevantEntities,
  } from '#inventory/lib/importer/import_helpers'
  import isbnExtractor from '#inventory/lib/importer/extract_isbns'
  import screen_ from '#lib/screen'
  import app from '#app/app'
  import log_ from '#lib/loggers'
  import FileImporter from './file_importer.svelte'
  import IsbnImporter from './isbn_importer.svelte'
  import Counter from '#components/counter.svelte'
  import Spinner from '#components/spinner.svelte'
  import { icon } from '#lib/handlebars_helpers/icons'

  export let candidates, isbns, processing
  export let processedExternalEntriesCount = 0
  export let totalExternalEntries = 0

  let cancelled
  let externalEntries = []
  let flashBlockingProcess
  let bottomSectionElement = {}

  const createExternalEntries = candidatesData => {
    flashBlockingProcess = null
    externalEntries = _.compact(candidatesData.map(createExternalEntry))
  }

  // Start from a different number at each session to avoid
  // "Cannot have duplicate keys in a keyed each" errors in development
  let externalEntryIndexCount = Date.now()

  const createExternalEntry = candidateData => {
    const { isbn, title, authors = [] } = candidateData
    let externalEntry = {
      index: externalEntryIndexCount++,
      editionTitle: title,
      authors: authors.map(name => ({ label: name })),
    }
    delete candidateData.title
    delete candidateData.authors
    Object.assign(externalEntry, candidateData)
    if (isbn) externalEntry.isbnData = isbnExtractor.getIsbnData(isbn)
    if (externalEntry.isbnData?.isInvalid) return
    return externalEntry
  }

  const createCandidatesQueue = async () => {
    if (noNewCandidates({ externalEntries, candidates })) {
      flashBlockingProcess = { type: 'warning', message: 'no new book found' }
      return
    }
    processedExternalEntriesCount = 0
    totalExternalEntries = externalEntries.length
    const remainingExternalEntries = _.clone(externalEntries)
    screen_.scrollToElement(bottomSectionElement)

    const createCandidateOneByOne = async () => {
      if (cancelled) return processedExternalEntriesCount = 0
      if (remainingExternalEntries.length === 0) return
      const externalEntry = remainingExternalEntries.pop()
      const normalizedIsbn = externalEntry.isbnData?.normalizedIsbn
      // Wont prevent duplicated candidates when 2 identical isbns are processed
      // at the same time in separate threads (see below createCandidatesQueue)
      // this is acceptable, as long as it prevents duplicates from one import to another
      let entitiesRes
      try {
        if (!externalEntry.editionTitle) {
          // not enough data for the resolver, so get edition by uri directly
          entitiesRes = await getEditionEntitiesByUri(normalizedIsbn)
        } else {
          const resolveOptions = { update: true }
          const resEntry = await resolveCandidate(externalEntry, resolveOptions)
          const { edition, works } = resEntry
          entitiesRes = await getRelevantEntities(edition, works)
        }
      } catch (err) {
        log_.error(err, 'no entities found err')
      }
      createAndAssignCandidate(externalEntry, entitiesRes)
      await createCandidateOneByOne()
      // Log errors without throwing to prevent crashing the whole chain
      .catch(log_.Error('createCandidateOneByOne err'))
    }

    return Promise.all([
      // Using 5 separate channels, fetching entities one by one, instead of
      // by batch, to avoid having one entity blocking a batch progression:
      createCandidateOneByOne(),
      createCandidateOneByOne(),
      createCandidateOneByOne(),
      createCandidateOneByOne(),
      createCandidateOneByOne()
    ])
    .then(async () => {
      // Display candidates in the order of the input
      // to help the user fill the missing information
      candidates = candidates.sort(byIndex)
      // Add counts only now in order to handle entities redirects
      await addExistingItemsCounts()
    })
    .finally(() => cancelled = false)
  }

  const addExistingItemsCounts = async function () {
    const uris = _.compact(externalEntries.map(externalEntry => guessUriFromIsbn({ externalEntry })))
    const counts = await app.request('items:getEntitiesItemsCount', app.user.id, uris)
    candidates = candidates.map(addExistingItemsCountToCandidate(counts))
  }

  const createAndAssignCandidate = (externalEntry, entities) => {
    processedExternalEntriesCount += 1
    const newCandidate = createCandidate(externalEntry, entities)
    candidates = [ ...candidates, newCandidate ]
  }

  $: processing = (processedExternalEntriesCount !== totalExternalEntries) && processedExternalEntriesCount > 0
</script>
<h3>1/ {I18n('upload your books from another website')}</h3>
<ul class="importers">
  {#each importers as importer (importer.name)}
    <li>
      <FileImporter {importer} {createExternalEntries} {createCandidatesQueue} />
    </li>
  {/each}
  <li>
    <IsbnImporter {createExternalEntries} {createCandidatesQueue} {isbns}/>
  </li>
</ul>
<Flash bind:state={flashBlockingProcess}/>
<div bind:this={bottomSectionElement}></div>
{#if processing}
  <div class="processing-menu">
    <Counter count={processedExternalEntriesCount} total={totalExternalEntries}/>
    <button
      class="grey-button dangerous"
      disabled={cancelled}
      on:click="{() => cancelled = true}"
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
  @import '#modules/general/scss/utils';
  h3{
    padding-left: 0.2em;
    font-weight: bold;
    margin-top: 1em;
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
