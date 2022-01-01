<script>
  import { onMount } from 'svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import Flash from '#lib/components/flash.svelte'
  import autosize from 'autosize'
  import importers from '#inventory/lib/importers'
  import commonParser from '#inventory/lib/parsers/common'
  import dataValidator from '#inventory/lib/data_validator'
  import files_ from '#lib/files'
  import { preCandidateUri, createCandidate } from '#inventory/lib/import_helpers'
  import isbnExtractor from '#inventory/lib/import/extract_isbns'
  import screen_ from '#lib/screen'
  import preq from '#lib/preq'
  import app from '#app/app'
  import log_ from '#lib/loggers'

  export let candidates
  export let preCandidatesCount
  let preCandidates = []
  let flashImporters = {}
  let isbnsText
  let flashIsbnsImporter, flashImportCandidates
  let bottomSectionElement = {}

  let processedPreCandidates = 0

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
    .then(createAndResolveCandidates)
    .catch(log_.ErrorRethrow('parsing error'))
    .catch(message => flashImporters[importer.name] = { type: 'error', message })
  }

  const onIsbnsChange = async () => {
    if (!isbnsText || isbnsText.length === 0) return
    window.ISBN = window.ISBN || (await import('isbn3')).default
    autosize(document.querySelector('textarea'))
    flashIsbnsImporter = null

    const isbnPattern = /(97(8|9))?[\d-]{9,14}([\dX])/g
    const isbns = isbnsText.match(isbnPattern)
    if (isbns == null) return flashIsbnsImporter = { type: 'error', message: 'no new ISBN found' }
    const candidatesData = isbns.map(isbn => { return { isbn } })

    createPreCandidates(candidatesData)
  }

  const createPreCandidates = candidatesData => {
    preCandidates = _.compact(candidatesData.map(createPreCandidate))
  }

  const createPreCandidate = candidateData => {
    const { isbn } = candidateData
    const preCandidate = candidateData
    if (isbn) preCandidate.isbnData = isbnExtractor.getIsbnData(isbn)
    if (!isAlreadyCandidate(preCandidate.isbnData.normalizedIsbn)) return preCandidate
  }

  const createAndResolveCandidates = async () => {
    processedPreCandidates = 0
    flashImportCandidates = null
    preCandidatesCount = preCandidates.length
    await addExistingItemsCounts()
    const remainingPreCandidates = _.clone(preCandidates)
    const createCandidateOneByOne = async () => {
      if (remainingPreCandidates.length === 0) return
      const preCandidate = remainingPreCandidates.pop()
      const nextUri = `isbn:${preCandidate.isbnData.normalizedIsbn}`
      if (!isAlreadyCandidate(preCandidate.isbn)) {
        await preq.get(app.API.entities.getByUris(nextUri, false, relatives))
        .catch(err => { log_.error(err, 'resolver err') })
        .then(createCandidatesFromEntities(preCandidate))
      }
      processedPreCandidates += 1
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
    .then(() => screen_.scrollToElement(bottomSectionElement.offsetTop))
  }

  // Fetch the works associated to the editions, and those works authors
  // to get access to the authors labels
  const relatives = [ 'wdt:P629', 'wdt:P50' ]

  const addExistingItemsCounts = function () {
    const uris = _.compact(preCandidates.map(preCandidateUri))
    return app.request('items:getEntitiesItemsCount', app.user.id, uris)
    .then(addCounts(preCandidates))
  }

  const addCounts = () => function (counts) {
    preCandidates.forEach(preCandidate => {
      const uri = preCandidateUri(preCandidate)
      if (uri == null) return
      const count = counts[uri]
      if (count != null) preCandidate.existingItemsCount = count
    })

    return preCandidates
  }

  const createCandidatesFromEntities = preCandidate => res => {
    if (!res) return
    const newCandidate = createCandidate(preCandidate, res.entities)
    candidates = [ ...candidates, newCandidate ]
  }
  const isAlreadyCandidate = normalizedIsbn => _.some(candidates, haveIsbn(normalizedIsbn))

  const haveIsbn = isbn => candidate => candidate.preCandidate.isbnData?.normalizedIsbn === isbn

  const emptyIsbns = () => isbnsText = ''

  // dev stuff, delete before production
  isbnsText = ',9782352946847,9782352946847,2277119660,1591841380,978-2-207-11674-6'
  Promise.resolve(onIsbnsChange()).then(createAndResolveCandidates)
</script>
<div id="importersElement">
  <h3>1/ {I18n('upload your books from another website')}</h3>
  <ul class="importers">
    {#each importers as importer (importer.name)}
      <li id="{importer.name}-li">
        <div class="importer-data">
          <p class="importerName">
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
            <p class="help">{@html I18n(importer.help)}</p>
          {/if}
        </div>
        <input id="{importer.name}" name="{importer.name}" type="file" bind:files={importer.files} accept="{importer.accept}" on:change={getFile(importer)}/>
        <!-- <div class="loading"></div> -->
        <Flash bind:state={flashImporters[importer.name]}/>
      </li>
    {/each}
    <li id="textIsbns-li">
      <div id="isbnsImporter">
        {I18n('import from a list of ISBNs')}
        <div class="textarea-wrapper">
          <textarea id="isbnsTextarea" bind:value={isbnsText} aria-label="{i18n('isbns list')}" placeholder="{i18n('paste any kind of text containing ISBNs here')}" on:change="{onIsbnsChange}"></textarea>
          <a id="emptyIsbns" title="{i18n('clear')}" on:click={emptyIsbns}>{@html icon('trash-o')}</a>

        </div>
        <Flash bind:state={flashIsbnsImporter}/>
        <div class="loading"></div>
      </div>
    </li>
  </ul>
</div>
<div class="buttonWrapper">
  <a id="createCandidatesButton" on:click={createAndResolveCandidates} class="button">{I18n('find ISBNs')}</a>
</div>
<div bind:this={bottomSectionElement}></div>
<style>
  h3{
    margin-top: 1em;
    text-align: center;
  }
  input{
    padding: auto 0;
  }
  .importerName, #isbnsImporter{
    margin: 0 0.7em;
  }
  .buttonWrapper{
    margin: 1em;
    text-align:center;
  }

</style>
