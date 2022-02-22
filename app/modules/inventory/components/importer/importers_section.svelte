<script>
  import { I18n } from '#user/lib/i18n'
  import Flash from '#lib/components/flash.svelte'
  import importers from '#inventory/lib/importers'
  import { guessUriFromIsbn, createCandidate, noNewCandidates, byIndex, isAlreadyCandidate, addExistingItemsCountToCandidate } from '#inventory/lib/import_helpers'
  import isbnExtractor from '#inventory/lib/import/extract_isbns'
  import screen_ from '#lib/screen'
  import preq from '#lib/preq'
  import app from '#app/app'
  import log_ from '#lib/loggers'
  import FileImporter from './file_importer.svelte'
  import IsbnImporter from './isbn_importer.svelte'

  export let candidates
  export let processedPreCandidatesCount = 0
  export let totalPreCandidates = 0
  let preCandidates = []
  let flashBlockingProcess, flashOngoingProcess
  let bottomSectionElement = {}

  const createPreCandidates = candidatesData => {
    flashOngoingProcess = null
    flashBlockingProcess = null
    const invalidIsbns = []
    preCandidates = _.compact(candidatesData.map(createPreCandidate(invalidIsbns)))
    if (invalidIsbns.length > 0 && candidates.length > 0) {
      const invalidRawIsbns = invalidIsbns.map(_.property('isbn'))
      const message = I18n('invalid_isbns_warning', { invalidIsbns: invalidRawIsbns.join(', ') })
      flashOngoingProcess = { type: 'warning', message }
    }
  }

  let preCandidateIndexCount = 0

  const createPreCandidate = invalidIsbns => candidateData => {
    const { isbn, title, authors } = candidateData
    if (isAlreadyCandidate(isbn, candidates)) return
    let preCandidate = {
      index: preCandidateIndexCount,
      customWorkTitle: title,
      customAuthorsNames: authors,
    }
    delete candidateData.title
    delete candidateData.authors
    Object.assign(preCandidate, candidateData)
    preCandidateIndexCount += 1
    if (isbn) preCandidate.isbnData = isbnExtractor.getIsbnData(isbn)
    if (preCandidate.isbnData?.isInvalid) {
      invalidIsbns.push(preCandidate)
      // do not return to avoid creating an invalid preCandidate
    } else {
      return preCandidate
    }
  }

  const createCandidatesQueue = async () => {
    if (noNewCandidates({ preCandidates, candidates })) {
      flashBlockingProcess = { type: 'warning', message: 'no new book found' }
      return
    }
    processedPreCandidatesCount = 0
    totalPreCandidates = preCandidates.length
    const remainingPreCandidates = _.clone(preCandidates)
    screen_.scrollToElement(bottomSectionElement.offsetTop)

    const createCandidateOneByOne = async () => {
      if (remainingPreCandidates.length === 0) return
      const preCandidate = remainingPreCandidates.pop()
      if (preCandidate.isbnData) {
        const { normalizedIsbn } = preCandidate.isbnData
        const nextUri = `isbn:${normalizedIsbn}`
        // wont prevent doublons candidates if 2 identical isbns are processed
        // at the same time in separate channels (see below)
        // this is acceptable, as long as it prevent doublons from one import to another
        if (!isAlreadyCandidate(normalizedIsbn, candidates)) {
          await preq.get(app.API.entities.getByUris(nextUri, false, relatives))
          .catch(err => {
            log_.error(err, 'no entities found err')
          })
          .then(createAndAssignCandidate(preCandidate))
        }
      } else {
        createAndAssignCandidate(preCandidate)()
      }
      // increase batch size to reduce queries amount on the long run
      // while serving first results quickly
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

  // Fetch the works associated to the editions, and those works authors
  // to get access to the authors labels
  const relatives = [ 'wdt:P629', 'wdt:P50' ]

  const addExistingItemsCounts = async function () {
    const uris = _.compact(preCandidates.map(preCandidate => guessUriFromIsbn({ preCandidate })))
    const counts = await app.request('items:getEntitiesItemsCount', app.user.id, uris)
    candidates = candidates.map(addExistingItemsCountToCandidate(counts))
  }

  const createAndAssignCandidate = preCandidate => res => {
    processedPreCandidatesCount += 1
    const newCandidate = createCandidate(preCandidate, res)
    candidates = [ ...candidates, newCandidate ]
  }
</script>
<h3>1/ {I18n('upload your books from another website')}</h3>
<ul class="importers">
  {#each importers as importer (importer.name)}
    <li>
      <FileImporter {importer} {createPreCandidates} {createCandidatesQueue} />
    </li>
  {/each}
  <li>
    <IsbnImporter {createPreCandidates} {createCandidatesQueue} />
  </li>
</ul>
<Flash bind:state={flashBlockingProcess}/>
<div bind:this={bottomSectionElement}></div>
<!-- The flash element is here to be able to view it while scrolling down to candidates section -->
<Flash bind:state={flashOngoingProcess}/>
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
