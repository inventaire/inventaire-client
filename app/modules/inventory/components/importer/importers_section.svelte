<script>
  import { I18n } from '#user/lib/i18n'
  import Flash from '#lib/components/flash.svelte'
  import importers from '#inventory/lib/importers'
  import {
    guessUriFromIsbn,
    createCandidate,
    noNewCandidates,
    byIndex,
    isAlreadyCandidate,
    addExistingItemsCountToCandidate,
    resolveEntryAndFetchEntities,
    getEditionEntitiesByUri,
    formatCandidatesData,
  } from '#inventory/lib/import_helpers'
  import isbnExtractor from '#inventory/lib/import/extract_isbns'
  import screen_ from '#lib/screen'
  import app from '#app/app'
  import log_ from '#lib/loggers'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import FileImporter from './file_importer.svelte'
  import IsbnImporter from './isbn_importer.svelte'

  export let candidates
  export let processedExternalEntriesCount = 0
  export let totalExternalEntries = 0
  export let isbns

  let externalEntries = []
  let flashBlockingProcess
  let bottomSectionElement = {}

  const createExternalEntries = candidatesData => {
    flashBlockingProcess = null
    externalEntries = _.compact(candidatesData.map(createExternalEntry))
  }

  let externalEntryIndexCount = 0

  const createExternalEntry = candidateData => {
    const { isbn, title, authors } = candidateData
    if (isAlreadyCandidate(isbn, candidates)) return
    let externalEntry = {
      index: externalEntryIndexCount++,
      customWorkTitle: title,
      customAuthorsNames: authors,
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
    screen_.scrollToElement(bottomSectionElement.offsetTop)

    const createCandidateOneByOne = async () => {
      if (remainingExternalEntries.length === 0) return
      const externalEntry = remainingExternalEntries.pop()
      const { normalizedIsbn } = externalEntry.isbnData
      // wont prevent doublons candidates if 2 identical isbns are processed
      // at the same time in separate channels (see below createCandidateOneByOne)
      // this is acceptable, as long as it prevents doublons from one import to another
      let entitiesRes
      if (!isAlreadyCandidate(normalizedIsbn, candidates)) {
        try {
          if (!externalEntry.customWorkTitle) {
            // not enough data for the resolver, so get edition by uri directly
            entitiesRes = await getEditionEntitiesByUri(normalizedIsbn)
          } else {
            entitiesRes = await resolveEntryAndFetchEntities(externalEntry)
          }
        } catch (err) {
          log_.error(err, 'no entities found err')
        }
      }
      createAndAssignCandidate(externalEntry, entitiesRes)
      createCandidateOneByOne()
      // log errors without throwing to prevent crashing the whole chain
      .catch(log_.Error('createCandidateOneByOne err'))
    }

    return Promise.all([
      // Using 5 separate channels, fetching entities one by one, instead of
      // by batch, to avoid having one entity blocking a batch progression:
      // the hypothesis is that the request overhead should be smaller than
      // the time a new dataseed-based entity might take to be created
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
      // add counts only now in order to handle entities redirects
      await addExistingItemsCounts()
    })
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

  if (isNonEmptyArray(isbns)) {
    const candidatesData = formatCandidatesData(isbns)
    createExternalEntries(candidatesData)
    Promise.resolve(createCandidatesQueue())
  }
</script>
<h3>1/ {I18n('upload your books from another website')}</h3>
<ul class="importers">
  {#each importers as importer (importer.name)}
    <li>
      <FileImporter {importer} {createExternalEntries} {createCandidatesQueue} />
    </li>
  {/each}
  <li>
    <IsbnImporter {createExternalEntries} {createCandidatesQueue} />
  </li>
</ul>
<Flash bind:state={flashBlockingProcess}/>
<div bind:this={bottomSectionElement}></div>
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
</style>
