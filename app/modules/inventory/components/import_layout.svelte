<script>
  import { onMount } from 'svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import files_ from '#lib/files'
  import _ from 'underscore'
  import autosize from 'autosize'
  import Flash from '#lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'
  import SelectButtonGroup from '#inventory/components/select_button_group.svelte'
  import CandidatesElement from '#inventory/components/importer/candidates_element.svelte'
  import dataValidator from '#inventory/lib/data_validator'
  import isbnExtractor from '#inventory/lib/import/extract_isbns'
  import importers from '#inventory/lib/importers'
  import commonParser from '#inventory/lib/parsers/common'
  import screen_ from '#lib/screen'
  import log_ from '#lib/loggers'
  import preq from '#lib/preq'
  import { createCandidate, preCandidateUri } from '#inventory/lib/import_helpers'
  import app from '#app/app'

  onMount(() => autosize(document.querySelector('textarea')))

  let flashIsbnsImporter, flashImportCandidates, flashImportSuccess

  let flashImporters = {}
  let isbnsText, preCandidatesCount
  let candidates = []
  let candidatesElement = {}
  let preCandidates = []
  let candidatesLength
  let processedPreCandidates = 0
  let transaction, listing
  let processedCandidates = 0

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
    // create preCandidate without isbn and only with new isbn
    if (!isAlreadyCandidate(preCandidate.isbnData.normalizedIsbn)) return preCandidate
  }

  const createAndResolveCandidates = async () => {
    processedPreCandidates = 0
    flashImportCandidates = flashImportSuccess = null
    preCandidatesCount = preCandidates.length
    await addExistingItemsCounts()
    const remainingPreCandidates = _.clone(preCandidates)
    const createCandidateOneByOne = async () => {
      const preCandidate = remainingPreCandidates.pop()
      const nextUri = `isbn:${preCandidate.isbnData.normalizedIsbn}`
      if (!isAlreadyCandidate(preCandidate.isbn)) {
        await preq.get(app.API.entities.getByUris(nextUri, false, relatives))
        .catch(err => { log_.error(err, 'resolver err') })
        .then(createCandidatesFromEntities(preCandidate))
      }
      if (remainingPreCandidates.length === 0) return
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
    .then(() => screen_.scrollToElement(candidatesElement.offsetTop))
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

  const importCandidates = async () => {
    let importingCandidates
    if (importingCandidates) return flashImportCandidates = { type: 'warning', message: I18n('already importing some books') }
    importingCandidates = true
    if (_.isEmpty(candidates)) return flashImportCandidates = { type: 'warning', message: I18n('no book selected') }
    const remainingCandidates = _.clone(candidates)
    const candidatesErr = []

    const createItem = async () => {
      const nextCandidate = remainingCandidates.splice(0, 1)[0]
      if (nextCandidate.checked) {
        const { uri: editionUri } = nextCandidate.edition
        if (editionUri) {
          await app.request('item:create', {
            transaction,
            listing,
            details: nextCandidate.details,
            entity: editionUri
          })
          .catch(err => {
            candidatesErr.push(nextCandidate)
            flashImportCandidates = { type: 'error', message: I18n('something went wrong, retry?') }
            log_.error(err, 'createItem err')
          })
        }
      }
      if (remainingCandidates.length === 0) return
      processedCandidates += 1
      await createItem()
    }

    return createItem()
    .then(flashImportCandidates = { type: 'success', message: I18n('import completed') })
    .catch(err => {
      log_.error(candidatesErr, 'createItem from candidates err', { err })
    })
    .finally(() => {
      processedCandidates = 0
      importingCandidates = false
    })
  }

  $: candidatesLength = candidates.length
  // dev stuff, delete before production
  isbnsText = ',9782352946847,9782352946847,2277119660,1591841380,978-2-207-11674-6'
  Promise.resolve(onIsbnsChange()).then(createAndResolveCandidates)
</script>
<div id='importLayout'>
  <div id="importersWrapper">
    <h3>1/ {I18n('upload your books')}</h3>
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
  <div hidden="{!candidates.length > 0}">
    <div id="candidatesElement" bind:this={candidatesElement}>
      <CandidatesElement bind:candidates {preCandidatesCount}/>
    </div>
    <h3>3/ {I18n('select the settings to apply to the selected books')}</h3>
    <div class="itemsSettings">
      <SelectButtonGroup type="transaction" bind:selected={transaction}/>
      <SelectButtonGroup type="listing" title="visibility" bind:selected={listing}/>
    </div>
    <h3>4/ {I18n('import this batch')}</h3>
    <div class="importCandidates">
      <Flash bind:state={flashImportCandidates}/>
      {#if flashImportCandidates?.type === 'success'}
        <button
          href="/"
          class="button"
          on:click="{() => app.execute('show:home')}"
          >{I18n('See the new books in my inventory')}</button>
      {:else}
        {#if processedCandidates > 0 && processedCandidates < candidatesLength}
          <p class="loading">
            {processedCandidates}/{candidatesLength}
            <Spinner/>
          </p>
        {/if}
        <button
          class="importCandidatesButton button success"
          on:click={importCandidates}
          >
          {I18n('import the selection')}
        </button>
      {/if}
    </div>
  </div>
</div>

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  #importLayout{
    @include display-flex(column);
    margin: 0 auto;
    max-width: 70em;
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
  h3{
    margin-top: 1em;
    text-align: center;
  }
  .importCandidates{
    @include display-flex(column, center, center, wrap);
  }
  .importCandidates {
    button { margin: 1em 0; }
    text-align:center;
  }
</style>
