<script>
  import { onMount } from 'svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import Flash from '#lib/components/flash.svelte'
  import autosize from 'autosize'
  import importers from '#inventory/lib/importers'
  import commonParser from '#inventory/lib/parsers/common'
  import dataValidator from '#inventory/lib/data_validator'
  import files_ from '#lib/files'
  import { guessUriFromIsbn, createCandidate } from '#inventory/lib/import_helpers'
  import isbnExtractor from '#inventory/lib/import/extract_isbns'
  import screen_ from '#lib/screen'
  import preq from '#lib/preq'
  import app from '#app/app'
  import log_ from '#lib/loggers'

  export let candidates
  export let processedPreCandidatesCount = 0
  export let totalPreCandidates = 0
  let preCandidates = []
  let flashImporters = {}
  let isbnsText
  let flashBlockingProcess, flashOngoingProcess
  let bottomSectionElement = {}

  onMount(() => autosize(document.querySelector('textarea')))

  const getFile = importer => {
    const { parse, encoding, files } = importer
    // TODO: refactor by turning parsers into async functions
    // which import their dependencies themselves
    flashImporters = {}
    return Promise.all([
      files_.readFile('readAsText', files[0], encoding, true),
      import('papaparse'),
      import('isbn3'),
    ])
    // We only need the result from the file
    .then(([ data, { default: Papa }, { default: ISBN } ]) => {
      window.ISBN = ISBN
      window.Papa = Papa
      dataValidator(importer, data)
      return parse(data).map(commonParser)
    })
    .then(createPreCandidates)
    .then(createCandidatesQueue)
    .catch(log_.ErrorRethrow('parsing error'))
    .catch(message => flashImporters[importer.name] = { type: 'error', message })
  }

  const onIsbnsChange = async () => {
    if (!isbnsText || isbnsText.length === 0) return
    window.ISBN = window.ISBN || (await import('isbn3')).default
    autosize(document.querySelector('textarea'))
    flashBlockingProcess = null

    const isbnPattern = /(97(8|9))?[\d-]{9,14}([\dX])/g
    const isbns = isbnsText.match(isbnPattern)
    if (isbns === null) return flashBlockingProcess = { type: 'error', message: 'no ISBN found' }
    const candidatesData = isbns.map(isbn => { return { isbn } })
    createPreCandidates(candidatesData)
  }

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
    if (isAlreadyCandidate(isbn)) return
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
    if (noNewCandidates()) return flashBlockingProcess = { type: 'warning', message: 'no new book found' }
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

  const noNewCandidates = () => {
    const preCandidatesIsbns = getNormalizedIsbns(preCandidates)
    const candidatesIsbns = getNormalizedIsbns(candidates)
    return preCandidatesIsbns.every(isCandidateIsbn(candidatesIsbns))
  }

  const getNormalizedIsbns = candidates => _.compact(candidates.map(candidate => candidate.isbnData?.normalizedIsbn))

  const isCandidateIsbn = candidatesIsbns => preCandidateIsbn => candidatesIsbns.includes(preCandidateIsbn)

  const byIndex = (a, b) => a.index - b.index

  const isAlreadyCandidate = normalizedIsbn => _.some(candidates, haveIsbn(normalizedIsbn))

  const haveIsbn = isbn => candidate => candidate.isbnData?.normalizedIsbn === isbn

  // Fetch the works associated to the editions, and those works authors
  // to get access to the authors labels
  const relatives = [ 'wdt:P629', 'wdt:P50' ]

  const addExistingItemsCounts = function () {
    const uris = _.compact(preCandidates.map(preCandidate => guessUriFromIsbn({ preCandidate })))
    return app.request('items:getEntitiesItemsCount', app.user.id, uris)
    .then(counts => candidates = candidates.map(addCountToCandidate(counts)))
  }

  const addCountToCandidate = counts => candidate => {
    const { isbnData } = candidate
    const uri = guessUriFromIsbn({ isbnData })
    if (uri == null) return candidate
    const count = counts[uri]
    if (count != null) candidate.existingItemsCount = count
    return candidate
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
      <div class="importer-data">
        <p class="importer-name">
          {#if importer.link}
            <a name={importer.label} href={importer.link}>{importer.label}</a>
          {:else}
            <span title={importer.label}>{importer.label}</span>
          {/if}
          {#if importer.format && importer.format !== 'all'}
            <span class="format">( .{importer.format} )</span>
          {/if}
        </p>
        {#if importer.help}
          <p>{@html I18n(importer.help)}</p>
        {/if}
      </div>
      <input id="{importer.name}" name="{importer.name}" type="file" bind:files={importer.files} accept="{importer.accept}" on:change={getFile(importer)}/>
      <Flash bind:state={flashImporters[importer.name]}/>
    </li>
  {/each}
  <li>
    <div class="importer-name">
      {I18n('import from a list of ISBNs')}
      <div class="textarea-wrapper">
        <textarea id="isbnsTextarea" bind:value={isbnsText} aria-label="{i18n('isbns list')}" placeholder="{i18n('paste any kind of text containing ISBNs here')}" on:change="{onIsbnsChange}"></textarea>
        <button id="emptyIsbns" class="grey-button" title="{i18n('clear')}" on:click="{isbnsText = ''}">
          {I18n('clear text')}
        </button>
      </div>
    </div>
  </li>
</ul>
<Flash bind:state={flashBlockingProcess}/>
<div class="button-wrapper">
  <a id="createCandidatesButton" on:click={createCandidatesQueue} class="success-button">{I18n('find ISBNs')}</a>
</div>
<div bind:this={bottomSectionElement}></div>
<!-- The flash element is here to be able to view it while scrolling down to candidates section -->
<Flash bind:state={flashOngoingProcess}/>
<style lang="scss">
  @import '#modules/general/scss/utils';
  h3{
    margin-top: 1em;
    text-align: center;
  }
  .importer-data{
    @include display-flex(row, center);
  }
  .textarea-wrapper{
    @include display-flex(row, flex-start);
    #isbnsTextarea{
      margin: 0;
    }
    #emptyIsbns{
      padding: 0.5em;
      margin-left: 0.5em;
      max-width: 5em;
    }
  }
  input{
    padding: auto 0;
  }
  .importer-name{
    margin: 0 0.7em;
    /*overrides #addLayout*/
    text-align: left;
  }
  .button-wrapper{
    padding-top:2em;
    padding-bottom:2em;
    text-align:center;
  }
</style>
